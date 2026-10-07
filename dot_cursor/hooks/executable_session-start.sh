#!/usr/bin/env bash
# Inject global agent instructions into every cursor-agent session.
# Cursor has no file-based global rules; sessionStart additional_context fills the gap.
set -euo pipefail

files=("$HOME/.cursor/AGENTS.md" "$HOME/.claude/RTK.md")
context=""
for f in "${files[@]}"; do
  [[ -r $f ]] && context+="$(cat "$f")"$'\n\n'
done

jq -n --arg ctx "$context" '{additional_context: $ctx}'
