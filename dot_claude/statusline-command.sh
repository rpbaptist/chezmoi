#!/bin/bash
# Claude Code status line.
# Directory/git segments mirror the Starship config at ~/.config/starship.toml.
# Model name and context-remaining segments are Claude Code defaults.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# ANSI colors approximating the starship palette (dark background theme)
YELLOW='\033[33m'
BRIGHT_RED='\033[91m'
BRIGHT_CYAN='\033[96m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
GREEN='\033[32m'
RESET='\033[0m'

# Directory segment - mirrors starship [directory]
dir_name=$(basename "$cwd")
if [ -w "$cwd" ]; then
  dir_segment=$(printf "${YELLOW}%s${RESET}" "$dir_name")
else
  dir_segment=$(printf "${YELLOW}%s ${BRIGHT_RED}\xf3\xb0\x8c\xbe${RESET}" "$dir_name")
fi

# Git branch segment - mirrors starship [git_branch] + [git_status]
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -z "$status" ]; then
      indicator="✔"
    elif echo "$status" | grep -q '^??'; then
      indicator="?"
    else
      indicator="≠"
    fi
    git_segment=$(printf " ${BRIGHT_CYAN}\xf3\xb0\x98\xac %s %s${RESET}" "$branch" "$indicator")
  fi
fi

# Model segment - Claude Code default
model_segment=$(printf " ${BRIGHT_BLUE}%s${RESET}" "$model")

# Context-remaining segment - Claude Code default
context_segment=""
if [ -n "$remaining" ]; then
  remaining_int=$(printf "%.0f" "$remaining")
  if [ "$remaining_int" -lt 20 ]; then
    ctx_color="$BRIGHT_RED"
  else
    ctx_color="$GREEN"
  fi
  context_segment=$(printf " ${ctx_color}%s%% left${RESET}" "$remaining_int")
fi

printf "%b" "${dir_segment}${git_segment}${model_segment}${context_segment}"
