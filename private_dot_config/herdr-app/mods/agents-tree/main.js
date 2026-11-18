// Agents as herdr-tui shows them: every agent, grouped by space, then tab, each
// with its status word, how long it has been in it, and its sub-agents nested.
// A sub-agent that is a herdr-chat chat opens as the chat, as in chat-agents.

import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, terminals, spaces, focused, run, theme, setAgentOrder, openOverlay, closeOverlay, layout } from "herdr";

const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
const WORD = { blocked: "blocked", done: "done", working: "working", idle: "idle" };
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

function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

const icon = (p, size, color) => !p?.icon ? null : p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "").trim();
const urgent = (sts) => sts.reduce((m, s) => ((RANK[s] ?? 0) > (RANK[m] ?? 0) ? s : m), null);
// A sub-agent without a pane reports a raw word; error counts as blocked, and its done is its parent's news.
const kidStatus = (k, listed) => {
  const s = listed.get(k.address) ?? k.status;
  return s === "error" ? "blocked" : s === "done" ? "idle" : s;
};

let chat = null; // the chat dialog this list opened last

function peek(addr) {
  const t = terminals().find((x) => x.address === addr);
  const id = t?.labels?.["herdr-chat.chat"];
  if (!id) return run("terminal.peek", { terminal: addr });
  run("overlay.close", { id: "terminal-peek" });
  if (chat) closeOverlay(chat);
  const provider = t.labels["herdr-chat.provider"];
  chat = openOverlay({ mod: "chat", kind: "dialog", width: 0.8, height: 0.8, props: { chat: id, peek: addr, ...(provider ? { provider } : {}) } });
}

export default class AgentsTree extends View {
  init(_props, cx) {
    this.folded = new Set(JSON.parse(localStorage.getItem("folded") ?? "[]"));
    this.changed = JSON.parse(localStorage.getItem("changed") ?? "{}");
    cx.timer.every(30000, (cx) => cx.notify());
  }

  // When each agent entered its state; done and idle count as one.
  track(list, now) {
    let dirty = false;
    for (const a of list) {
      const s = a.status === "done" ? "idle" : a.status;
      if (this.changed[a.address]?.s === s) continue;
      this.changed[a.address] = { s, at: now };
      dirty = true;
    }
    if (!dirty) return;
    const listed = new Set(list.map((a) => a.address));
    for (const [k, c] of Object.entries(this.changed)) if (!listed.has(k) && now - c.at > 30 * 86400000) delete this.changed[k];
    localStorage.setItem("changed", JSON.stringify(this.changed));
  }

  fold(id, cx) {
    this.folded.has(id) ? this.folded.delete(id) : this.folded.add(id);
    localStorage.setItem("folded", JSON.stringify([...this.folded]));
    cx.notify();
  }

  // Live sub-agents of `addr`, depth first, with their tree lines.
  tree(all, addr, lead = []) {
    const kids = all.filter((k) => k.parent === addr && k.state === "live");
    return kids.flatMap((k, i) => {
      const last = i === kids.length - 1;
      return [{ t: k, depth: lead.length, lines: [...lead, last ? "└" : "├"] }, ...this.tree(all, k.address, [...lead, last ? " " : "│"])];
    });
  }

  word(t, status, compact) {
    const color = t[status] ?? t.dim;
    const glyph = status === "working"
      ? svg(ICON("spinner")).size(11).flex_none().text_color(color).spin(900)
      : status === "idle" ? div().size(7).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim)
      : div().size(7).flex_none().rounded(4).bg(color);
    if (compact) return glyph;
    return h_flex().flex_none().gap(5).items_center()
      .child(glyph)
      .child(div().text_size(11).font_medium().text_color(status === "idle" ? t.dim : color).child(WORD[status] ?? status ?? ""));
  }

  agentRow(t, a, primary, secondary, indent, subs, now) {
    const when = this.changed[a.address]?.at;
    const on = a.focused;
    const pic = icon(a.program, 14, a.status === "idle" ? t.muted : t.foreground);
    return h_flex().id(`ag-${a.address}`).h(26).pl(indent).pr(8).gap(7).flex_none().items_center().rounded(7)
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .cursor_pointer()
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .on_mouse_down("right", () => openOverlay({ mod: "chat-menu", kind: "popup", width: 240, props: { tab: "pane", target: { terminal: a.address } } }))
      .when(subs.length > 0, (el) => el.child(div().id(`agf-${a.address}`).flex_none().text_color(t.dim)
        .on_click((_e, cx) => { cx.stop_propagation(); this.fold(a.address, cx); })
        .child(svg(ICON(`chevron-${this.folded.has(a.address) ? "right" : "down"}`)).size(10))))
      .when(Boolean(pic), (el) => el.child(pic))
      .child(h_flex().flex_1().min_w(0).gap(5).items_center()
        .child(div().min_w(0).flex_shrink(0).max_w(150).truncate().text_color(a.status === "idle" && !on ? t.muted : t.foreground).child(primary))
        .when(Boolean(secondary), (el) => el.child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(secondary))))
      .when(Boolean(when), (el) => el.child(div().flex_none().text_size(10.5).text_color(t.dim).child(duration(now - when))))
      .child(this.word(t, a.status, false));
  }

  subRow(t, s, indent, listed, shown) {
    const k = s.t;
    const st = kidStatus(k, listed);
    const on = k.address === shown;
    const pic = icon(k.program, 12, t.muted);
    return h_flex().id(`sub-${k.address}`).h(24).pl(indent).pr(8).gap(5).flex_none().items_center().rounded(7)
      .when(on, (el) => el.bg(t.raised))
      .hover((el) => el.bg(t.hover)).cursor_pointer()
      .on_click(() => (listed.has(k.address) ? run("pane.focus", { terminal: k.address }) : peek(k.address)))
      .child(div().flex_none().text_size(11).text_color(t.input).child(s.lines.join(" ")))
      .when(Boolean(pic), (el) => el.child(pic))
      .child(div().flex_1().min_w(0).truncate().text_size(12).text_color(on ? t.foreground : t.muted).child(k.name || k.template || k.program?.name || k.address))
      .child(this.word(t, st, false));
  }

  render(cx) {
    const t = theme();
    const collapsed = narrow();
    const now = Date.now();
    const all = terminals();
    let list = agents();
    const listed = new Map(list.map((a) => [a.address, a.status]));
    this.track(list, now);
    const shown = focused()?.agent;
    // A kept sub-agent shows under its parent, not on its own.
    const nested = new Set(list.flatMap((a) => this.tree(all, a.address).map((s) => s.t.address)));
    list = list.filter((a) => !nested.has(a.address));
    const order = [];
    const rows = [];
    const counts = { blocked: 0, done: 0, working: 0, idle: 0 };
    for (const a of agents()) counts[a.status] = (counts[a.status] ?? 0) + 1;

    for (const sp of spaces()) {
      const mine = list.filter((a) => a.space === sp.id);
      if (!mine.length) continue;
      const kidsOf = new Map(mine.map((a) => [a.address, this.tree(all, a.address)]));
      const status = urgent(mine.flatMap((a) => [a.status, ...kidsOf.get(a.address).map((s) => kidStatus(s.t, listed))]));
      const open = !this.folded.has(sp.id);
      if (collapsed) {
        for (const a of mine) {
          order.push(a.address);
          rows.push(h_flex().id(`ag-${a.address}`).h(24).justify_center().items_center().rounded(6)
            .when(a.focused, (el) => el.bg(t.selected)).hover((s) => s.bg(t.hover))
            .tooltip(`${sp.name} · ${a.tab_name} · ${a.status}`)
            .on_click(() => run("pane.focus", { pane: a.pane })).child(this.word(t, a.status, true)));
        }
        continue;
      }
      rows.push(h_flex().id(`sp-${sp.id}`).h(28).px(8).mt(4).gap(7).flex_none().items_center().rounded(7)
        .cursor_pointer().hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.fold(sp.id, cx))
        .child(svg(ICON(`chevron-${open ? "down" : "right"}`)).size(10).flex_none().text_color(t.dim))
        .child(div().flex_shrink(0).max_w(140).truncate().font_medium().text_color(sp.active ? t.foreground : t.muted).child(sp.name))
        .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(t.dim).child(sp.branch && sp.branch !== sp.name ? sp.branch : ""))
        .when(!open, (el) => el.child(div().text_size(11).text_color(t.dim).child(String(mine.length))))
        .child(this.word(t, status, true)));
      if (!open) continue;
      const tabs = [];
      for (const a of mine) {
        const last = tabs.at(-1);
        if (last?.id === a.tab) last.members.push(a);
        else tabs.push({ id: a.tab, name: a.tab_name, named: sp.tabs.find((x) => x.id === a.tab)?.named, members: [a] });
      }
      for (const tab of tabs) {
        const many = tab.members.length > 1;
        if (many) rows.push(h_flex().id(`tab-${tab.id}`).h(22).pl(26).pr(8).gap(6).flex_none().items_center().text_size(11.5).text_color(t.dim)
          .cursor_pointer().hover((s) => s.text_color(t.foreground))
          .on_click(() => run("tab.select", { id: tab.id }))
          .child(svg(ICON("terminal")).size(11).flex_none()).child(div().truncate().child(tab.name)));
        for (const a of tab.members) {
          order.push(a.address);
          const program = a.program?.name ?? "";
          const title = clean(a.title);
          const telling = title && title !== program && !/^[~/]/.test(title) && !title.includes("@");
          // One agent in a tab: the tab speaks for it. Several: each its own title.
          const primary = many ? (telling ? title : program) : tab.named ? tab.name : (telling ? title : program || tab.name);
          const secondary = many ? (telling ? program : "") : tab.named ? (telling ? title : program) : (telling ? program : `tab ${tab.name}`);
          const subs = kidsOf.get(a.address);
          const indent = many ? 40 : 26;
          rows.push(this.agentRow(t, a, primary, secondary, indent, subs, now));
          if (!this.folded.has(a.address)) rows.push(...subs.map((s) => this.subRow(t, s, indent + 14, listed, shown)));
        }
      }
    }
    setAgentOrder(order);

    const tally = ["blocked", "done", "working", "idle"].filter((s) => counts[s]).map((s) => h_flex().gap(3).items_center()
      .tooltip(`${counts[s]} ${WORD[s]}`).child(this.word(t, s, true)).child(div().text_size(11).text_color(t.dim).child(String(counts[s]))));

    return v_flex().size_full().min_h(0).bg(t.chrome).border_t(1).border_color(t.border).text_size(13)
      .when(!collapsed, (el) => el.child(h_flex().px(16).h(41).pt(14).pb(5).gap(10).flex_none().items_center()
        .child(div().flex_1().text_size(11.5).font_medium().text_color(t.dim).child("Agents"))
        .children(tally)))
      .when(!rows.length && !collapsed, (el) => el.child(div().px(16).text_size(12).text_color(t.dim).child("No agents running.")))
      .child(v_flex().id("agt-list").flex_1().min_h(0).px(collapsed ? 4 : 8).pb(10).overflow_y_scrollbar().mode("always").children(rows));
  }
}
