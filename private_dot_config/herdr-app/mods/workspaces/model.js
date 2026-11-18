// Repos, their worktrees and their GitHub pull requests, read with git, gh and wt.
// Local machine only.

import { exec, panes, spaces, agents } from "herdr";

const READ = ["--no-optional-locks", "-c", "core.fsmonitor=false"];
export const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
export const base = (path) => path.replace(/\/+$/, "").split("/").pop();
export const slug = (s) => s.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 48).replace(/-+$/, "");

export async function git(cwd, args, timeout = 30000) {
  try {
    const r = await exec("git", [...READ, ...args], { cwd, timeout });
    return { ok: r.code === 0, out: r.stdout.replace(/\n$/, ""), err: r.stderr.trim() };
  } catch (e) {
    return { ok: false, out: "", err: String(e?.message ?? e) };
  }
}

export async function gh(cwd, args, timeout = 30000) {
  try {
    const r = await exec("gh", args, { cwd, timeout });
    return { ok: r.code === 0, out: r.stdout, err: (r.stderr || r.stdout).trim() };
  } catch (e) {
    return { ok: false, out: "", err: String(e?.message ?? e) };
  }
}

// wt prints hook output around its JSON: take the last JSON value on stdout.
export async function wt(cwd, args, timeout = 600000) {
  try {
    const r = await exec("wt", [...args, "--format=json"], { cwd, timeout });
    const text = r.stdout;
    const at = Math.max(text.lastIndexOf("\n{"), text.lastIndexOf("\n["));
    let json = null;
    try { json = JSON.parse(at >= 0 ? text.slice(at + 1) : text); } catch {}
    return { ok: r.code === 0, json, err: (r.stderr || r.stdout).trim().split("\n").filter((l) => !l.startsWith("◎")).slice(-4).join("\n") };
  } catch (e) {
    return { ok: false, json: null, err: String(e?.message ?? e) };
  }
}

// { main, name } of the repo that holds `folder`, or null outside git.
export async function repoOf(folder) {
  const r = await git(folder, ["rev-parse", "--path-format=absolute", "--git-common-dir"]);
  if (!r.ok) return null;
  const main = r.out.replace(/\/\.git\/?$/, "");
  return { main, name: base(main) };
}

// Every checkout of the repo, main first: { path, branch, main }.
export async function checkouts(main) {
  const r = await git(main, ["worktree", "list", "--porcelain"]);
  if (!r.ok) return [];
  const out = [];
  for (const block of r.out.split(/\n\n+/)) {
    const lines = block.split("\n");
    const path = lines.find((l) => l.startsWith("worktree "))?.slice(9);
    if (!path || lines.some((l) => l === "bare" || l.startsWith("prunable"))) continue;
    const branch = lines.find((l) => l.startsWith("branch "))?.slice(7).replace(/^refs\/heads\//, "") ?? null;
    out.push({ path, branch, main: out.length === 0 });
  }
  return out;
}

// Ahead, behind and changed files of one checkout, from one status call.
export async function state(path) {
  const r = await git(path, ["status", "--porcelain=2", "--branch", "--untracked-files=normal"]);
  if (!r.ok) return { ahead: 0, behind: 0, dirty: 0, upstream: false };
  let ahead = 0, behind = 0, dirty = 0, upstream = false;
  for (const l of r.out.split("\n")) {
    if (l.startsWith("# branch.upstream ")) upstream = true;
    else if (l.startsWith("# branch.ab ")) [ahead, behind] = l.slice(12).split(" ").map((n) => Math.abs(Number(n)));
    else if (l && !l.startsWith("#")) dirty++;
  }
  return { ahead, behind, dirty, upstream };
}

export function checksOf(rollup) {
  if (!rollup?.length) return null;
  let pending = false;
  for (const c of rollup) {
    const v = (c.conclusion || c.state || "").toUpperCase();
    if (["FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"].includes(v)) return "fail";
    if ((c.status && c.status !== "COMPLETED") || v === "PENDING" || v === "EXPECTED" || v === "") pending = true;
  }
  return pending ? "pending" : "pass";
}

const PR_FIELDS = "number,title,headRefName,state,isDraft,reviewDecision,statusCheckRollup,url,updatedAt";

// Branch -> its pull request (an open one before closed or merged ones), or null when gh can't answer.
export async function pulls(main) {
  const r = await gh(main, ["pr", "list", "--state", "all", "--limit", "100", "--json", PR_FIELDS]);
  if (!r.ok) return null;
  const byBranch = {};
  let list = [];
  try { list = JSON.parse(r.out); } catch { return null; }
  for (const p of list) {
    const pr = { number: p.number, title: p.title, state: p.isDraft && p.state === "OPEN" ? "DRAFT" : p.state, review: p.reviewDecision || null, checks: checksOf(p.statusCheckRollup), url: p.url, at: p.updatedAt };
    const have = byBranch[p.headRefName];
    const open = (x) => x.state === "OPEN" || x.state === "DRAFT";
    if (!have || (open(pr) && !open(have)) || (open(pr) === open(have) && pr.at > have.at)) byBranch[p.headRefName] = pr;
  }
  return byBranch;
}

// The branch origin/HEAD names (origin/main), else the local default.
export async function defaultBase(main) {
  const r = await git(main, ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"]);
  return r.ok && r.out ? r.out : "^";
}

// Where a space is now: its first terminal's live folder, else where it was made.
export function place(s, ps = panes()) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder || null;
}

const inside = (dir, path) => dir === path || dir?.startsWith(path + "/");

// The local space showing a checkout: the one whose place is deepest inside it.
export function spaceFor(path, paths, ps = panes()) {
  for (const s of spaces()) {
    if (s.machine) continue;
    const at = place(s, ps);
    if (!inside(at, path)) continue;
    // A nested checkout (repo.feature inside repo) owns its own spaces.
    if (paths.some((p) => p !== path && p.length > path.length && inside(at, p))) continue;
    return s;
  }
  return null;
}

export function urgent(list) {
  return list.reduce((m, a) => ((RANK[a.status] ?? 0) > (RANK[m] ?? 0) ? a.status : m), null);
}

export const agentsIn = (space) => (space ? agents().filter((a) => a.space === space.id) : []);

export async function openUrl(url) {
  try { await exec("xdg-open", [url]); } catch {}
}
