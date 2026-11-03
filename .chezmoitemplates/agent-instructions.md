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

Remove, after the PR state is `MERGED`: run `wt remove <branch>`, then close
the herdr workspace of the worktree if it is still open
(`herdr workspace list`, then `herdr workspace close <id>`).

When `herdr` is not running or `wt` is missing, use plain `git worktree`.
