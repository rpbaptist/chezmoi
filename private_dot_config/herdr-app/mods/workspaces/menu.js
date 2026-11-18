// Right-click menu of a repo header or a worktree row.

import { div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, openOverlay, theme, shared, setShared, spaces, notify } from "herdr";
import { git, gh, wt, openUrl, agentsIn } from "./model.js";

const poke = () => setShared("workspaces.poke", Date.now());

function showChanges(spaceId) {
  if (spaceId) run("space.select", { id: spaceId });
  run("layout.show", { id: "panel" });
  run("layout.select", { stack: "panel-body", child: "changes" });
}

export class Menu {
  init(_props, cx) {
    this.confirm = null; // the item waiting for its second click
    this.busy = null;
    this.error = "";
  }

  close() {
    closeOverlay(props().overlay);
  }

  openNew(extra) {
    const p = props();
    this.close();
    openOverlay({ mod: "workspaces", kind: "dialog", width: 560, height: 560, props: { view: "new", main: p.main, name: p.name, ...extra } });
  }

  // Runs a slow step with the menu open, so a failure can say why.
  task(id, cx, work) {
    this.busy = id;
    this.error = "";
    cx.notify();
    cx.spawn(async (cx) => {
      let err = "";
      try { err = (await work()) ?? ""; } catch (e) { err = String(e?.message ?? e); }
      this.busy = null;
      if (err) { this.error = err; cx.notify(); }
      else this.close();
    });
  }

  repoItems(p) {
    return [
      ["new", "New worktree…", "plus", () => this.openNew({})],
      ["fetch", "Fetch and prune", "git-compare", (cx) => this.task("fetch", cx, async () => {
        const r = await git(p.main, ["fetch", "--all", "--prune", "--quiet"], 120000);
        poke();
        return r.ok ? "" : r.err;
      })],
      p.gh && ["gh", "Open repository on GitHub", "file-text", () => { gh(p.main, ["repo", "view", "--web"]); this.close(); }],
      ["hide", "Hide from Workspaces", "minus", () => {
        setShared("workspaces.hidden", [...new Set([...(shared("workspaces.hidden") ?? []), p.main])]);
        setShared("workspaces.repos", (shared("workspaces.repos") ?? []).filter((m) => m !== p.main));
        this.close();
      }],
    ];
  }

  worktreeItems(p) {
    const space = spaces().find((s) => s.id === p.space) ?? null;
    const open = () => space ? run("space.select", { id: space.id }) : run("space.new", { name: p.isMain ? p.name : p.branch, folder: p.path });
    const live = agentsIn(space).filter((a) => a.status === "working" || a.status === "blocked");
    const merged = p.pr?.state === "MERGED";
    return [
      ["open", space ? "Go to space" : "Open as space", "folder", () => { open(); this.close(); }],
      ["agent", "New agent here…", "square-pen", () => this.openNew({ mode: "agent", path: p.path, branch: p.branch })],
      ["changes", "Show changes", "git-compare", () => {
        if (!space) open();
        this.close();
        showChanges(space?.id);
      }],
      p.pr && ["pr", `Show PR #${p.pr.number}`, "file-text", () => {
        const pr = { view: "pr", path: p.path, branch: p.branch, main: p.main, name: p.name };
        this.close();
        if (!space) return openOverlay({ mod: "workspaces", kind: "dialog", width: 0.8, height: 0.85, props: pr });
        run("space.select", { id: space.id });
        run("pane.split", { direction: "right", mod: "workspaces", props: pr });
      }],
      p.pr && ["web", "Open PR on GitHub", "file-text", () => { openUrl(p.pr.url); this.close(); }],
      !p.pr && p.gh && !p.isMain && p.branch && ["create", "Push and create PR", "git-branch", (cx) => this.task("create", cx, async () => {
        const push = await git(p.path, ["push", "-u", "origin", "HEAD"], 120000);
        if (!push.ok) return push.err;
        const r = await gh(p.path, ["pr", "create", "--web", "--head", p.branch], 60000);
        poke();
        return r.ok ? "" : r.err;
      })],
      ["copy", "Copy path", "files", (cx) => { cx.write_to_clipboard(p.path); this.close(); }],
      !p.isMain && p.branch && ["remove", merged ? "Remove worktree (PR merged)" : "Remove worktree", "archive", (cx) => {
        if (live.length) { this.error = "An agent in this worktree is working or waiting for you. Stop it first."; cx.notify(); return; }
        if (this.confirm !== "remove") { this.confirm = "remove"; cx.notify(); return; }
        this.task("remove", cx, async () => {
          // A squash merge looks unmerged to git: after a merged PR, -D is safe.
          const r = await wt(p.main, ["remove", p.branch, "--yes", ...(merged ? ["-D"] : [])]);
          if (!r.ok) { this.confirm = "force"; return `${r.err || "wt remove failed."}\nClick "Force remove" to delete it anyway.`; }
          if (space) run("space.close", { id: space.id });
          poke();
          notify({ title: `Removed ${p.branch}`, level: "success", timeout: 4000 });
        });
      }],
      this.confirm === "force" && ["force", "Force remove (loses changes)", "x", (cx) => this.task("force", cx, async () => {
        const r = await wt(p.main, ["remove", p.branch, "--yes", "--force", "-D"]);
        if (!r.ok) return r.err || "wt remove failed.";
        if (space) run("space.close", { id: space.id });
        poke();
      })],
    ];
  }

  render(cx) {
    const t = theme();
    const p = props();
    const items = (p.kind === "repo" ? this.repoItems(p) : this.worktreeItems(p)).filter(Boolean);
    const title = p.kind === "repo" ? p.name : p.branch ?? p.path;
    return v_flex().w_full().p(5).bg(t.popover).text_size(12.8)
      .child(div().px(8).pt(4).pb(6).text_size(11).text_color(t.dim).truncate().child(title))
      .children(items.map(([id, label, icon, act]) => {
        const danger = id === "force" || (id === "remove" && this.confirm === "remove");
        return h_flex().id(`mi-${id}`).h(30).px(8).gap(9).rounded(7).items_center()
          .text_color(danger ? t.blocked : t.foreground).hover((el) => el.bg(t.hover))
          .on_click((_e, cx) => act(cx))
          .child(svg(`mods/workspace-chrome/${icon}.svg`).size(14).flex_none().text_color(danger ? t.blocked : t.muted))
          .child(div().flex_1().truncate().child(id === "remove" && this.confirm === "remove" ? "Click again to remove" : label))
          .when(this.busy === id, (el) => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).text_color(t.muted).spin(900)));
      }))
      .when(Boolean(this.error), (el) => el.child(div().px(8).py(6).text_size(11.5).text_color(t.blocked).child(this.error)));
  }
}
