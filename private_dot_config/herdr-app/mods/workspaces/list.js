// The sidebar: repos, each with its worktrees (open as spaces or not), their git
// state, agents and pull request. Spaces outside any repo come last.

import { div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, panes, run, openOverlay, theme, shared, setShared, window, layout, pickFolder, watchFolder, nextCommand, notify } from "herdr";
import { repoOf, checkouts, state, pulls, place, spaceFor, agentsIn, urgent, base } from "./model.js";

const GIT_EVERY = 10000;
const GH_EVERY = 60000;
const MARK = ["#22a99a", "#e3814f", "#5b8def", "#8b7cf6", "#3fae6a", "#d9649a"];
const ICON = (n) => `mods/workspace-chrome/${n}.svg`;

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

function hue(name) {
  let h = 0;
  for (const c of name) h = (h * 31 + c.charCodeAt(0)) >>> 0;
  return MARK[h % MARK.length];
}

export function statusDot(t, status) {
  if (status === "working") return svg(ICON("spinner")).size(11).flex_none().text_color(t.working).spin(900);
  if (status === "blocked") return div().size(8).flex_none().rounded(4).bg(t.blocked);
  if (status === "done") return div().size(8).flex_none().rounded(4).bg(t.done);
  if (status === "idle") return div().size(8).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
  return div().size(8).flex_none();
}

export function prBadge(t, pr) {
  const color = { OPEN: t.ansi2, DRAFT: t.dim, MERGED: t.ansi5, CLOSED: t.ansi1 }[pr.state] ?? t.dim;
  return h_flex().flex_none().gap(3).px(5).h(17).rounded(5).items_center().bg(color + "22").text_size(10.5).font_semibold().text_color(color)
    .child(`#${pr.number}`);
}

const CHECK = { pass: ["✓", "ansi2", "Checks pass"], fail: ["✗", "ansi1", "Checks fail"], pending: ["◌", "ansi3", "Checks running"] };
const REVIEW = { APPROVED: ["approved", "ansi2"], CHANGES_REQUESTED: ["changes", "ansi1"], REVIEW_REQUIRED: ["review", "ansi3"] };

export class List {
  init(_props, cx) {
    this.repos = new Map(); // main -> { main, name, wts, prs, gitAt, ghAt }
    this.placeRepo = new Map(); // a space's place -> repo main, or null
    this.folded = new Set(JSON.parse(localStorage.getItem("folded") ?? "[]"));
    this.watching = new Set();
    this.tick(cx);
    cx.timer.every(1500, (cx) => this.tick(cx));
    // Keys: workspaces.new (a worktree of the shown space's repo), workspaces.pr (its pull request).
    cx.spawn(async () => {
      for (;;) {
        const c = await nextCommand();
        const at = this.shown();
        if (!at) { notify({ title: "The shown space is not in a repository Workspaces knows.", level: "warning", timeout: 4000 }); continue; }
        if (c === "new") this.newDialog(at.r);
        else if (c === "pr") {
          if (!at.pr) { notify({ title: `No pull request for ${at.w.branch ?? "this checkout"}.`, level: "info", timeout: 4000 }); continue; }
          run("pane.split", { direction: "right", mod: "workspaces", props: { view: "pr", path: at.w.path, branch: at.w.branch } });
        }
      }
    });
  }

  // The shown space's checkout: { r, w, pr }.
  shown() {
    const space = spaces().find((s) => s.active);
    if (!space) return null;
    const ps = panes();
    for (const r of this.repos.values()) {
      const paths = (r.wts ?? []).map((w) => w.path);
      for (const w of r.wts ?? []) if (spaceFor(w.path, paths, ps)?.id === space.id) return { r, w, pr: this.prOf(r, w) };
    }
    return null;
  }

  // The main checkout's branch is the base of other PRs, not the head of one.
  prOf(r, w) {
    return w.main ? null : r.prs?.[w.branch] ?? null;
  }

  // Finds repos for new places, then reads git and gh where due.
  tick(cx) {
    if (this.busy) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      try {
        const ps = panes();
        for (const s of spaces()) {
          if (s.machine) continue;
          const at = place(s, ps);
          if (!at || this.placeRepo.has(at)) continue;
          this.placeRepo.set(at, (await repoOf(at))?.main ?? null);
        }
        const hidden = new Set(shared("workspaces.hidden") ?? []);
        const wanted = new Set([...this.placeRepo.values(), ...(shared("workspaces.repos") ?? [])].filter((m) => m && !hidden.has(m)));
        for (const m of wanted) if (!this.repos.has(m)) this.repos.set(m, { main: m, name: base(m), wts: null, prs: undefined, gitAt: 0, ghAt: 0 });
        for (const m of [...this.repos.keys()]) if (!wanted.has(m)) this.repos.delete(m);
        const now = Date.now();
        const poke = shared("workspaces.poke") ?? 0;
        const front = window()?.active !== false;
        await Promise.all([...this.repos.values()].map(async (r) => {
          if (r.wts === null || r.gitAt < poke || (front && now - r.gitAt > GIT_EVERY)) await this.readGit(r, cx);
          if (r.prs === undefined || r.ghAt < poke || (front && now - r.ghAt > GH_EVERY)) await this.readGh(r);
        }));
      } finally {
        this.busy = false;
        cx.notify();
      }
    });
  }

  async readGit(r, cx) {
    r.gitAt = Date.now();
    const list = await checkouts(r.main);
    r.wts = await Promise.all(list.map(async (w) => ({ ...w, ...(await state(w.path)) })));
    this.watch(r.main, cx);
  }

  async readGh(r) {
    r.ghAt = Date.now();
    const prs = await pulls(r.main);
    // gh said no (not a GitHub repo, offline): keep what it said before, ask again later.
    if (prs) r.prs = prs;
    else r.prs ??= null;
  }

  // A branch, worktree or commit made elsewhere shows at once.
  watch(main, cx) {
    if (this.watching.has(main)) return;
    this.watching.add(main);
    cx.spawn(async (cx) => {
      try {
        while (this.repos.has(main)) {
          await watchFolder(`${main}/.git`);
          const r = this.repos.get(main);
          if (r) { await this.readGit(r, cx); cx.notify(); }
        }
      } catch {}
      this.watching.delete(main);
    });
  }

  fold(id, cx) {
    this.folded.has(id) ? this.folded.delete(id) : this.folded.add(id);
    localStorage.setItem("folded", JSON.stringify([...this.folded]));
    cx.notify();
  }

  openWorktree(r, w, space) {
    if (space) run("space.select", { id: space.id });
    else run("space.new", { name: w.main ? r.name : w.branch ?? base(w.path), folder: w.path });
  }

  newDialog(r, extra = {}) {
    openOverlay({ mod: "workspaces", kind: "dialog", width: 560, height: 560, props: { view: "new", main: r.main, name: r.name, ...extra } });
  }

  menu(props) {
    openOverlay({ mod: "workspaces", kind: "popup", width: 240, height: 420, props: { view: "menu", ...props } });
  }

  async addRepo(cx) {
    const folder = await pickFolder({ prompt: "Add repository" });
    if (!folder) return;
    const r = await repoOf(folder);
    if (!r) return;
    setShared("workspaces.repos", [...new Set([...(shared("workspaces.repos") ?? []), r.main])]);
    setShared("workspaces.hidden", (shared("workspaces.hidden") ?? []).filter((m) => m !== r.main));
    this.tick(cx);
  }

  repoHeader(t, r, count, status) {
    const open = !this.folded.has(r.main);
    return h_flex().id(`repo-${r.main}`).h(30).px(8).mt(4).gap(8).flex_none().items_center().rounded(8)
      .cursor_pointer().hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => this.fold(r.main, cx))
      .on_mouse_down("right", () => this.menu({ kind: "repo", main: r.main, name: r.name, gh: r.prs !== null }))
      .child(h_flex().size(18).flex_none().rounded(5).bg(hue(r.name)).items_center().justify_center().text_size(10.5).font_bold().text_color("#ffffff").child([...r.name][0]?.toUpperCase() ?? "?"))
      .child(div().flex_1().min_w(0).truncate().font_medium().text_color(t.foreground).child(r.name))
      .when(!open && Boolean(status), (el) => el.child(statusDot(t, status)))
      .when(!open, (el) => el.child(div().text_size(11).text_color(t.dim).child(String(count))))
      .child(div().id(`repo-new-${r.main}`).size(20).flex_none().flex().items_center().justify_center().rounded(5).text_color(t.dim)
        .hover((s) => s.bg(t.raised).text_color(t.foreground)).tooltip("New worktree")
        .on_click((_e, cx) => { cx.stop_propagation(); this.newDialog(r); })
        .child(svg(ICON("plus")).size(12)))
      .child(svg(ICON(`chevron-${open ? "down" : "right"}`)).size(11).flex_none().text_color(t.dim));
  }

  wtRow(t, r, w, space, list) {
    const pr = this.prOf(r, w);
    const status = urgent(list);
    const on = space?.active;
    const label = w.branch ?? `(detached) ${base(w.path)}`;
    const check = pr?.checks && CHECK[pr.checks];
    const review = pr?.review && (pr.state === "OPEN") && REVIEW[pr.review];
    const facts = [
      w.main ? div().text_color(t.dim).child("main checkout") : null,
      w.ahead ? div().text_color(t.ansi2).child(`↑${w.ahead}`) : null,
      w.behind ? div().text_color(t.ansi1).child(`↓${w.behind}`) : null,
      w.dirty ? div().text_color(t.ansi3).child(`±${w.dirty}`) : null,
      check ? div().text_color(t[check[1]]).child(`${check[0]} checks`) : null,
      review ? div().text_color(t[review[1]]).child(review[0]) : null,
      list.length ? div().text_color(t.dim).child(`${list.length} agent${list.length > 1 ? "s" : ""}`) : null,
      !space ? div().text_color(t.dim).child("not open") : null,
    ].filter(Boolean);
    const menuProps = { kind: "worktree", main: r.main, name: r.name, path: w.path, branch: w.branch, isMain: w.main, space: space?.id ?? null, gh: r.prs !== null, pr: pr && { number: pr.number, url: pr.url, state: pr.state } };
    return v_flex().id(`wt-${w.path}`).pl(16).pr(8).py(5).gap(2).flex_none().rounded(8)
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .cursor_pointer()
      .on_click(() => this.openWorktree(r, w, space))
      .on_mouse_down("right", () => this.menu(menuProps))
      .child(h_flex().gap(7).items_center()
        .child(h_flex().w(12).flex_none().justify_center().child(status ? statusDot(t, status) : svg(ICON("git-branch")).size(12).text_color(space ? t.muted : t.dim)))
        .child(div().flex_1().min_w(0).truncate().text_color(space ? t.foreground : t.muted).when(on, (el) => el.font_medium()).child(label))
        .when(Boolean(pr), (el) => el.child(prBadge(t, pr))))
      .when(Boolean(pr && pr.state !== "MERGED" && pr.state !== "CLOSED"), (el) => el.child(div().pl(19).truncate().text_size(11.5).text_color(t.muted).child(pr.title)))
      .when(facts.length > 0, (el) => el.child(h_flex().pl(19).gap(7).text_size(11).flex_wrap().children(facts)));
  }

  spaceRow(t, s) {
    const list = agentsIn(s);
    const status = urgent(list);
    return h_flex().id(`sp-${s.id}`).h(28).px(8).gap(8).flex_none().items_center().rounded(8)
      .when(s.active, (el) => el.bg(t.selected))
      .when(!s.active, (el) => el.hover((h) => h.bg(t.hover)))
      .on_click(() => run("space.select", { id: s.id }))
      .on_mouse_down("right", () => openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }))
      .child(h_flex().w(12).flex_none().justify_center().child(status ? statusDot(t, status) : svg(ICON(s.machine ? "server" : "folder")).size(12).text_color(t.dim)))
      .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(s.name))
      .when(Boolean(s.machine), (el) => el.child(div().text_size(10.5).text_color(t.dim).child(s.machine)))
      .when(list.length > 0, (el) => el.child(div().text_size(11).text_color(t.dim).child(String(list.length))));
  }

  render(cx) {
    const t = theme();
    const collapsed = narrow();
    const ps = panes();
    const claimed = new Set();
    const order = [];
    const rows = [];
    const repos = [...this.repos.values()].sort((a, b) => a.name.localeCompare(b.name));
    for (const r of repos) {
      const wts = r.wts ?? [];
      const paths = wts.map((w) => w.path);
      const items = wts.map((w) => {
        const space = spaceFor(w.path, paths, ps);
        if (space) claimed.add(space.id);
        const list = agentsIn(space);
        order.push(...list.map((a) => a.address));
        return { w, space, list };
      });
      const status = urgent(items.flatMap((i) => i.list));
      if (collapsed) {
        rows.push(...items.filter((i) => i.space).map((i) => h_flex().id(`wt-${i.w.path}`).h(26).justify_center().items_center().rounded(6)
          .when(i.space.active, (el) => el.bg(t.selected)).hover((s) => s.bg(t.hover))
          .tooltip(`${r.name} · ${i.w.branch ?? ""}`)
          .on_click(() => run("space.select", { id: i.space.id }))
          .child(i.list.length ? statusDot(t, urgent(i.list)) : div().text_size(11).text_color(t.muted).child([...r.name][0].toUpperCase()))));
        continue;
      }
      rows.push(this.repoHeader(t, r, items.length, status));
      if (this.folded.has(r.main)) continue;
      if (r.wts === null) rows.push(div().pl(16).h(24).text_size(12).text_color(t.dim).child("Reading…"));
      // Main checkout first, then worktrees with a space, then the rest.
      const rank = (i) => (i.w.main ? 0 : i.space ? 1 : 2);
      rows.push(...[...items].sort((a, b) => rank(a) - rank(b) || (a.w.branch ?? "").localeCompare(b.w.branch ?? "")).map((i) => this.wtRow(t, r, i.w, i.space, i.list)));
    }
    const others = spaces().filter((s) => !claimed.has(s.id) && !(s.machine === null && this.placeRepo.get(place(s, ps)) && this.repos.has(this.placeRepo.get(place(s, ps)))));
    if (others.length && !collapsed) {
      rows.push(h_flex().id("others").h(28).px(8).mt(6).items_center().text_size(11).text_color(t.dim).child("Other spaces"));
      rows.push(...others.map((s) => this.spaceRow(t, s)));
    }
    for (const s of others) order.push(...agentsIn(s).map((a) => a.address));
    this.order = order;

    return v_flex().size_full().min_h(0).bg(t.chrome).text_size(13)
      .child(h_flex().h(31).pl(16).pr(10).gap(2).items_center().text_size(11.5).text_color(t.dim)
        .when(collapsed, (el) => el.pl(0).pr(0).justify_center())
        .when(!collapsed, (el) => el.child(div().flex_1().child("Workspaces"))
          .child(div().id("ws-add-repo").size(26).flex_none().flex().items_center().justify_center().rounded(6).hover((s) => s.bg(t.hover).text_color(t.foreground))
            .tooltip("Add a repository").on_click((_e, cx) => cx.spawn(async (cx) => this.addRepo(cx)))
            .child(svg(ICON("folder-plus")).size(14))))
        .child(div().id("ws-new-space").size(26).flex_none().flex().items_center().justify_center().rounded(6).hover((s) => s.bg(t.hover).text_color(t.foreground))
          .tooltip("New space").on_click(() => run("space.new")).child(svg(ICON("plus")).size(14))))
      .child(v_flex().id("ws-list").flex_1().min_h(0).px(collapsed ? 4 : 8).pb(14).gap(1).overflow_y_scrollbar().mode("always")
        .when(rows.length === 0, (el) => el.child(div().px(8).py(6).text_size(12).text_color(t.dim).child("No repositories yet. Open a space in a git repo, or add one with the folder button.")))
        .children(rows));
  }
}
