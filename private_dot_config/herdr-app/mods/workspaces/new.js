// New worktree from a new branch, an issue, a pull request or an existing branch,
// made with wt (so its hooks run), opened as a space with an optional agent and task.
// mode "agent": no new worktree, only a new agent tab in `path`.

import { div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, TextareaState, Textarea } from "gpui-base";
import { run, props, closeOverlay, theme, spaces, knownAgents, setShared } from "herdr";
import { git, gh, wt, slug, defaultBase, spaceFor, checkouts } from "./model.js";

const MODES = [
  { id: "branch", label: "New branch" },
  { id: "issue", label: "From issue" },
  { id: "pr", label: "From PR" },
  { id: "existing", label: "Existing branch" },
];

export class New {
  init(_props, cx) {
    const p = props();
    this.mode = p.mode ?? "branch";
    this.items = {}; // mode -> [{ id, title, sub }] | "loading" | error string
    this.at = 0;
    this.busy = false;
    this.error = "";
    this.agents = null;
    this.agent = localStorage.getItem("agent") ?? "claude";
    this.input = InputState.new({ placeholder: this.placeholder() });
    this.input.on("change", (_e, cx) => { this.at = 0; this.error = ""; cx.notify(); });
    this.input.on("submit", (_e, cx) => this.go(cx));
    this.task = TextareaState.new({ placeholder: "Task for the agent (optional)", rows: 4 });
    this.handle = cx.focus_handle();
    if (this.mode === "agent") this.task.focus();
    else this.input.focus();
    cx.spawn(async (cx) => {
      try { this.agents = (await knownAgents()).filter((a) => a.installed); } catch { this.agents = []; }
      if (!this.agents.some((a) => a.key === this.agent)) this.agent = this.agents[0]?.key ?? "";
      cx.notify();
    });
    this.load(this.mode, cx);
  }

  placeholder() {
    return { branch: "branch name", agent: "tab name (optional)" }[this.mode] ?? "filter";
  }

  setMode(mode, cx) {
    this.mode = mode;
    this.at = 0;
    this.error = "";
    this.input.set_value("");
    this.input.focus();
    this.load(mode, cx);
    cx.notify();
  }

  load(mode, cx) {
    if (this.items[mode] || mode === "branch" || mode === "agent") return;
    this.items[mode] = "loading";
    const main = props().main;
    cx.spawn(async (cx) => {
      if (mode === "issue") {
        const r = await gh(main, ["issue", "list", "--state", "open", "--limit", "100", "--json", "number,title,labels"]);
        this.items.issue = r.ok ? JSON.parse(r.out).map((i) => ({ id: i.number, title: i.title, sub: `#${i.number}${i.labels?.length ? " · " + i.labels.map((l) => l.name).join(", ") : ""}` })) : r.err || "gh issue list failed.";
      } else if (mode === "pr") {
        const r = await gh(main, ["pr", "list", "--state", "open", "--limit", "100", "--json", "number,title,headRefName,author,isDraft"]);
        this.items.pr = r.ok ? JSON.parse(r.out).map((p) => ({ id: p.number, title: p.title, branch: p.headRefName, sub: `#${p.number} · ${p.headRefName} · ${p.author?.login ?? ""}${p.isDraft ? " · draft" : ""}` })) : r.err || "gh pr list failed.";
      } else if (mode === "existing") {
        const [refs, used] = await Promise.all([
          git(main, ["for-each-ref", "--sort=-committerdate", "--format=%(refname:short)%09%(committerdate:relative)", "refs/heads", "refs/remotes"]),
          checkouts(main),
        ]);
        const taken = new Set(used.map((w) => w.branch));
        const seen = new Set();
        this.items.existing = refs.ok ? refs.out.split("\n").filter(Boolean).map((l) => l.split("\t")).flatMap(([ref, when]) => {
          if (ref.endsWith("/HEAD") || ref === "origin") return [];
          const remote = ref.startsWith("origin/");
          const name = remote ? ref.slice(7) : ref;
          if (seen.has(name) || taken.has(name)) return [];
          seen.add(name);
          return [{ id: name, title: name, sub: `${remote ? "remote · " : ""}${when}` }];
        }) : refs.err;
      }
      cx.notify();
    });
  }

  filtered() {
    const list = this.items[this.mode];
    if (!Array.isArray(list)) return list;
    const q = this.input.value().trim().toLowerCase();
    return q ? list.filter((i) => `${i.title} ${i.sub}`.toLowerCase().includes(q)) : list;
  }

  close() {
    closeOverlay(props().overlay);
  }

  // What to make: { args for wt switch, name, task }, or an error string.
  async plan() {
    const p = props();
    const typed = this.input.value().trim();
    if (this.mode === "branch") {
      if (!typed) return "Type a branch name.";
      await git(p.main, ["fetch", "origin", "--quiet"], 60000);
      return { args: ["switch", "--create", typed, "--base", await defaultBase(p.main)], name: typed };
    }
    const list = this.filtered();
    const pick = Array.isArray(list) ? list[this.at] : null;
    if (!pick) return "Pick one from the list.";
    if (this.mode === "issue") {
      await git(p.main, ["fetch", "origin", "--quiet"], 60000);
      const branch = `${pick.id}-${slug(pick.title)}`;
      return { args: ["switch", "--create", branch, "--base", await defaultBase(p.main)], name: branch, task: `Work on GitHub issue #${pick.id}: ${pick.title}. Read it first with \`gh issue view ${pick.id} --comments\`.` };
    }
    if (this.mode === "pr") return { args: ["switch", `pr:${pick.id}`], name: pick.branch, task: `Review pull request #${pick.id}: ${pick.title}. Read it with \`gh pr view ${pick.id} --comments\` and \`gh pr diff ${pick.id}\`.` };
    return { args: ["switch", pick.id], name: pick.id };
  }

  go(cx) {
    if (this.busy) return;
    this.busy = true;
    this.error = "";
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const p = props();
        const program = this.agents?.find((a) => a.key === this.agent);
        const argv = program?.run;
        let task = this.task.value().trim();
        let path = p.path, name = p.branch;
        if (this.mode !== "agent") {
          const plan = await this.plan();
          if (typeof plan === "string") throw new Error(plan);
          const r = await wt(p.main, [...plan.args, "--no-cd", "--yes"]);
          if (!r.ok || !r.json?.path) throw new Error(r.err || "wt switch failed.");
          path = r.json.path;
          name = r.json.branch ?? plan.name;
          task ||= plan.task ?? "";
        }
        if (program) localStorage.setItem("agent", program.key);
        const agent = argv ? { argv, ...(task ? { task } : {}) } : {};
        const space = spaceFor(path, [path]);
        const tab = this.mode === "agent" ? this.input.value().trim() || undefined : undefined;
        if (space) run("tab.new", { space: space.id, folder: path, ...(tab ? { name: tab } : {}), ...agent });
        else run("space.new", { name: name ?? undefined, folder: path, ...(tab ? { tab } : {}), ...agent });
        setShared("workspaces.poke", Date.now());
        this.close();
      } catch (e) {
        this.error = String(e?.message ?? e);
        this.busy = false;
        cx.notify();
      }
    });
  }

  key(e, cx) {
    if (e.key === "escape") { cx.stop_propagation(); return this.close(); }
    const list = this.filtered();
    if (!Array.isArray(list) || !list.length) return;
    if (e.key === "down") { this.at = (this.at + 1) % list.length; cx.stop_propagation(); cx.notify(); }
    if (e.key === "up") { this.at = (this.at - 1 + list.length) % list.length; cx.stop_propagation(); cx.notify(); }
  }

  render(cx) {
    const t = theme();
    const p = props();
    const agentMode = this.mode === "agent";
    const list = this.filtered();
    const field = (el) => el.px(10).rounded(6).border(1).border_color(t.input).bg(t.background).text_color(t.foreground);
    return v_flex().id("ws-new").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .size_full().p(16).gap(10).bg(t.popover).text_size(13)
      .child(div().text_size(15).font_semibold().text_color(t.foreground).child(agentMode ? `New agent in ${p.branch ?? p.name}` : `New worktree of ${p.name}`))
      .when(!agentMode, (el) => el.child(h_flex().gap(4).children(MODES.map((m) => div().id(`mode-${m.id}`).px(10).h(26).flex().items_center().rounded(6).text_size(12)
        .when(m.id === this.mode, (el) => el.bg(t.selected).text_color(t.foreground))
        .when(m.id !== this.mode, (el) => el.text_color(t.muted).hover((s) => s.bg(t.hover)))
        .on_click((_e, cx) => this.setMode(m.id, cx)).child(m.label)))))
      .child(field(Input.new(this.input).h(32).items_center()))
      .when(this.mode !== "branch" && !agentMode, (el) => el.child(v_flex().id("ws-items").flex_1().min_h(0).overflow_y_scrollbar().gap(1)
        .when(list === "loading", (el) => el.child(div().text_color(t.dim).child("Loading…")))
        .when(typeof list === "string" && list !== "loading", (el) => el.child(div().text_color(t.blocked).child(list)))
        .when(Array.isArray(list) && !list.length, (el) => el.child(div().text_color(t.dim).child("Nothing matches.")))
        .when(Array.isArray(list), (el) => el.children(list.slice(0, 200).map((it, i) => v_flex().id(`it-${it.id}`).px(8).py(4).rounded(6).flex_none()
          .when(i === this.at, (el) => el.bg(t.selected))
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => { this.at = i; cx.notify(); })
          .child(div().truncate().text_color(t.foreground).child(it.title))
          .child(div().truncate().text_size(11).text_color(t.dim).child(it.sub)))))))
      .when(this.mode === "branch" || agentMode, (el) => el.child(div().flex_1()))
      .child(div().text_size(11.5).text_color(t.dim).child("Agent"))
      .child(h_flex().gap(4).flex_wrap()
        .children([...(this.agents ?? []).map((a) => [a.key, a.name]), ["", "Shell only"]].map(([key, name]) => div().id(`ag-${key || "none"}`).px(9).h(24).flex().items_center().rounded(6).text_size(12)
          .border(1).border_color(key === this.agent ? t.accent : t.border)
          .text_color(key === this.agent ? t.foreground : t.muted)
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => { this.agent = key; cx.notify(); }).child(name))))
      .when(Boolean(this.agent), (el) => el.child(field(Textarea.new(this.task).h(84).py(6))))
      .when(Boolean(this.error), (el) => el.child(div().text_size(12).text_color(t.blocked).child(this.error)))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_1().text_size(11).text_color(t.dim).child(this.mode === "branch" ? "Branches from the remote default branch." : agentMode ? "" : "↑↓ pick"))
        .child(div().id("ws-cancel").px(12).h(28).flex().items_center().rounded(6).text_color(t.muted).hover((s) => s.bg(t.hover)).on_click(() => this.close()).child("Cancel"))
        .child(div().id("ws-go").px(12).h(28).flex().items_center().gap(6).rounded(6).bg(t.solid).text_color(t.solid_foreground)
          .on_click((_e, cx) => this.go(cx))
          .when(this.busy, (el) => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).spin(900)))
          .child(this.busy ? "Working…" : agentMode ? "Start" : "Create")));
  }
}
