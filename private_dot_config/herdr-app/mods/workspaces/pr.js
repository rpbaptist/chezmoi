// A worktree's pull request: state, checks, reviews and every comment, inline ones
// by file and line. Props: { path, branch }.

import { div } from "gpui-kit";
import { v_flex, h_flex, TextView } from "gpui-base";
import { props, theme, run, closeOverlay, knownAgents } from "herdr";
import { gh, checksOf, openUrl, spaceFor } from "./model.js";
import { prBadge } from "./list.js";

const FIELDS = "number,title,state,isDraft,url,body,author,reviewDecision,statusCheckRollup,reviews,comments,headRefName,baseRefName,additions,deletions,changedFiles,mergeable,createdAt";
const ago = (iso) => {
  const d = (Date.now() - Date.parse(iso)) / 1000;
  return d < 3600 ? `${Math.max(1, Math.round(d / 60))}m` : d < 86400 ? `${Math.round(d / 3600)}h` : `${Math.round(d / 86400)}d`;
};
const CHECK_ICON = { pass: "✓", fail: "✗", pending: "◌" };

export class Pr {
  init(_props, cx) {
    this.pr = null;
    this.inline = [];
    this.error = "";
    this.load(cx);
    cx.timer.every(60000, (cx) => this.load(cx));
  }

  load(cx) {
    const { path, branch } = props();
    cx.spawn(async (cx) => {
      const r = await gh(path, ["pr", "view", branch, "--json", FIELDS]);
      if (!r.ok) { this.error = r.err || "No pull request for this branch."; cx.notify(); return; }
      this.pr = JSON.parse(r.out);
      this.error = "";
      const c = await gh(path, ["api", `repos/{owner}/{repo}/pulls/${this.pr.number}/comments`, "--paginate"]);
      try { this.inline = c.ok ? JSON.parse(c.out) : []; } catch { this.inline = []; }
      cx.notify();
    });
  }

  // An agent in this worktree reads every comment and works through them.
  address(cx) {
    const { path } = props();
    const n = this.pr.number;
    cx.spawn(async () => {
      let argv = ["claude"];
      try { argv = (await knownAgents()).find((a) => a.installed)?.run ?? argv; } catch {}
      const task = `Address the review feedback on pull request #${n}. Read it with \`gh pr view ${n} --comments\` and \`gh api repos/{owner}/{repo}/pulls/${n}/comments\`. Fix what is right, reply where you disagree, then push.`;
      const space = spaceFor(path, [path]);
      if (space) run("tab.new", { space: space.id, folder: path, name: `PR #${n} review`, argv, task });
      else run("space.new", { name: this.pr.headRefName, folder: path, argv, task });
      if (props().overlay) closeOverlay(props().overlay);
    });
  }

  render(cx) {
    const t = theme();
    const pr = this.pr;
    const btn = (id, label, act) => div().id(id).px(9).h(24).flex().items_center().rounded(6).text_size(12).border(1).border_color(t.border)
      .text_color(t.foreground).hover((s) => s.bg(t.hover)).on_click((_e, cx) => act(cx)).child(label);
    if (!pr) {
      return v_flex().size_full().p(16).gap(8).bg(t.background).text_size(13)
        .child(div().text_color(this.error ? t.blocked : t.dim).child(this.error || "Loading pull request…"))
        .when(Boolean(this.error), (el) => el.child(h_flex().child(btn("pr-retry", "Retry", (cx) => this.load(cx)))));
    }
    const state = pr.isDraft && pr.state === "OPEN" ? "DRAFT" : pr.state;
    const checks = pr.statusCheckRollup ?? [];
    const overall = checksOf(checks);
    const toneOf = (s) => ({ pass: t.ansi2, fail: t.ansi1, pending: t.ansi3 })[s] ?? t.dim;
    const one = (c) => checksOf([c]);
    // Reviews and conversation comments in time order; inline comments grouped by file.
    const thread = [
      ...(pr.reviews ?? []).filter((r) => r.body || r.state !== "COMMENTED").map((r) => ({ at: r.submittedAt, who: r.author?.login, what: r.state.toLowerCase().replace(/_/g, " "), body: r.body })),
      ...(pr.comments ?? []).map((c) => ({ at: c.createdAt, who: c.author?.login, what: "commented", body: c.body })),
    ].sort((a, b) => Date.parse(a.at) - Date.parse(b.at));
    const files = new Map();
    for (const c of this.inline) {
      const k = c.path;
      if (!files.has(k)) files.set(k, []);
      files.get(k).push(c);
    }
    const section = (label) => div().pt(10).pb(2).text_size(11).font_medium().text_color(t.dim).child(label);
    const note = (key, who, what, at, body) => v_flex().id(key).gap(3).p(8).rounded(8).bg(t.surface).border(1).border_color(t.border)
      .child(h_flex().gap(6).text_size(11.5).child(div().font_semibold().text_color(t.foreground).child(who ?? "?")).child(div().text_color(t.dim).child(`${what} · ${ago(at)}`)))
      .when(Boolean(body), (el) => el.child(TextView.markdown(`${key}-md`, body).selectable(true)));

    return v_flex().id("pr-root").size_full().min_h(0).bg(t.background).text_size(13)
      .child(v_flex().p(14).gap(6).flex_none().border_b(1).border_color(t.border)
        .child(h_flex().gap(8).items_center()
          .child(prBadge(t, { number: pr.number, state }))
          .child(div().flex_1().min_w(0).truncate().font_semibold().text_color(t.foreground).child(pr.title)))
        .child(h_flex().gap(8).text_size(11.5).text_color(t.dim).flex_wrap()
          .child(`${pr.headRefName} → ${pr.baseRefName}`)
          .child(div().text_color(t.ansi2).child(`+${pr.additions}`))
          .child(div().text_color(t.ansi1).child(`−${pr.deletions}`))
          .child(`${pr.changedFiles} files`)
          .when(Boolean(pr.reviewDecision), (el) => el.child(div().text_color(pr.reviewDecision === "APPROVED" ? t.ansi2 : pr.reviewDecision === "CHANGES_REQUESTED" ? t.ansi1 : t.ansi3).child(pr.reviewDecision.toLowerCase().replace(/_/g, " "))))
          .when(pr.mergeable === "CONFLICTING", (el) => el.child(div().text_color(t.ansi1).child("conflicts"))))
        .child(h_flex().gap(6).pt(4)
          .child(btn("pr-web", "Open on GitHub", () => openUrl(pr.url)))
          .child(btn("pr-refresh", "Refresh", (cx) => this.load(cx)))
          .when(state === "OPEN" || state === "DRAFT", (el) => el.child(btn("pr-address", "Agent: address feedback", (cx) => this.address(cx))))))
      .child(v_flex().id("pr-body").flex_1().min_h(0).p(14).gap(6).overflow_y_scrollbar()
        .when(checks.length > 0, (el) => el.child(section(`Checks ${CHECK_ICON[overall] ?? ""}`))
          .children(checks.map((c, i) => h_flex().id(`chk-${i}`).gap(8).h(22).items_center().text_size(12)
            .cursor_pointer().hover((s) => s.text_color(t.foreground))
            .on_click(() => (c.detailsUrl || c.targetUrl) && openUrl(c.detailsUrl || c.targetUrl))
            .child(div().w(12).text_color(toneOf(one(c))).child(CHECK_ICON[one(c)] ?? "·"))
            .child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(c.name || c.context || "check")))))
        .when(Boolean(pr.body), (el) => el.child(section("Description")).child(note("desc", pr.author?.login, "opened", pr.createdAt ?? new Date().toISOString(), pr.body)))
        .when(thread.length > 0, (el) => el.child(section("Conversation")).children(thread.map((c, i) => note(`c-${i}`, c.who, c.what, c.at, c.body))))
        .when(files.size > 0, (el) => el.child(section(`Inline comments · ${this.inline.length}`))
          .children([...files.entries()].flatMap(([file, list]) => [
            div().pt(4).text_size(12).font_medium().text_color(t.accent).truncate().child(file),
            ...list.map((c) => note(`ic-${c.id}`, c.user?.login, `line ${c.line ?? c.original_line ?? "?"}${c.in_reply_to_id ? " · reply" : ""}`, c.created_at, c.body)),
          ])))
        .when(!thread.length && !files.size && !pr.body, (el) => el.child(div().text_color(t.dim).child("No comments yet."))));
  }
}
