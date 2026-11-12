Respond with: No filler/hedging. Professional but tight. Use ASD-STE100.

All agents use ASD-STE100 for all communication. This includes subagents,
reports to a parent agent, and prompts that you write for a subagent. When
you start a subagent, tell it to use ASD-STE100.

Caveman mode is always on at level `lite`: keep articles and full sentences,
drop filler and hedging. `/caveman` without a level means `lite`. Use another
level only when I name it explicitly.


### Commit style

1. Limit the subject line to 70 characters
2. Separate subject from body with a blank line
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Use the body to explain what and why vs. how


### Session docs

Store session/troubleshooting docs in `~/.local/share/doc/`.
Machine-specific. Not chezmoi-managed.


### Screenshots

When I mention a screenshot and give no path, read the most recent file in
`~/Pictures/Screenshots/` (`ls -t ~/Pictures/Screenshots | head -1`).


### Worktrees

Applies to every agent on this machine. It overrides the worktree commands
in a repo's `AGENTS.md`. Keep the repo's rules (branch from fresh
`origin/main`, one worktree per task, cleanup after merge).

Make and remove worktrees with `wt` (worktrunk) so that its hooks run. Then
register the worktree with herdr, so it shows as a nested workspace. Do not
use `git worktree add` or `herdr worktree create`: they skip the hooks or
the herdr workspace.

Create, from the primary checkout or any worktree of the repo:

```bash
result=$(wt switch --create <branch> --base origin/main --no-cd --format=json)
herdr worktree open --cwd "$(git rev-parse --path-format=absolute --git-common-dir | xargs dirname)" \
  --path "$(jq -r .path <<<"$result")" --label <branch> --no-focus
```

Remove, after the PR state is `MERGED`: run `wt remove -D <branch>` (a squash
merge needs `-D`). A `post-remove` hook in the worktrunk user config closes
the herdr workspace.

When `herdr` is not running or `wt` is missing, use plain `git worktree`.

<!-- herdr-chat:subagents begin -->
## Sub-agents in Herdr
To start a Pi, Claude Code or Codex sub-agent, run `hc run --bg --name <name> pi-chat "<task>"` (or `claude-chat`, `codex-chat`), so the person can open it as a chat.
Use `hc run --bg --name <name> -- pi` (or `-- claude`, `-- codex`) only when you need its terminal UI.
Everything else is the same: `hc send`, `hc wait`, `hc read` and `hc kill` by name.
<!-- herdr-chat:subagents end -->
