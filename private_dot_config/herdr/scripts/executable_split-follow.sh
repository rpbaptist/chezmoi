#!/usr/bin/env bash
# Split the focused herdr pane. The new pane opens in the directory where the
# pane's agent session works now, for example a worktree that a Claude session
# moved into with `cd`. herdr's own "follow" policy uses the process cwd, which
# stays in the main checkout.
#
# Usage: split-follow.sh right|down
set -euo pipefail

direction=${1:-right}

pane=$(herdr pane list | jq -c '.result.panes[] | select(.focused)' | head -n 1)
[[ -n $pane ]] || exit 0

pane_id=$(jq -r .pane_id <<<"$pane")
cwd=$(jq -r '.foreground_cwd // .cwd // empty' <<<"$pane")

# A Claude session records its current cwd in each transcript entry.
if [[ $(jq -r '.agent // empty' <<<"$pane") == claude ]]; then
  session=$(jq -r '.agent_session.value // empty' <<<"$pane")
  if [[ -n $session ]]; then
    projects="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
    transcript=$(compgen -G "$projects/*/$session.jsonl" | head -n 1 || true)
    if [[ -n $transcript ]]; then
      session_cwd=$(tail -n 50 "$transcript" | jq -r 'select(.cwd) | .cwd' 2>/dev/null | tail -n 1)
      [[ -d $session_cwd ]] && cwd=$session_cwd
    fi
  fi
fi

args=(pane split "$pane_id" --direction "$direction" --focus)
[[ -d $cwd ]] && args+=(--cwd "$cwd")
exec herdr "${args[@]}" >/dev/null
