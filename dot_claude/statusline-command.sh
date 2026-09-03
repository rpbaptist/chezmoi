#!/bin/bash
# Claude Code status line.
# Directory/git segments mirror the Starship config at ~/.config/starship.toml
# (same path-truncation and git-status logic), as plain colored text — no
# background fill, since Starship's truecolor block half-painted certain
# glyphs here and wasn't worth chasing further. Model name and
# context-remaining segments are Claude Code additions with no Starship
# equivalent.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

RESET=$'\033[0m'
YELLOW=$'\033[33m'
BRIGHT_RED=$'\033[91m'
BRIGHT_CYAN=$'\033[96m'
BRIGHT_YELLOW=$'\033[93m'
BRIGHT_BLUE=$'\033[94m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
BOLD=$'\033[1m'

ICON_LOCK=$'\U000f033e'
ICON_BRANCH=$'\U000f062c'
ICON_AHEAD=$'\U0000f062'
ICON_BEHIND=$'\U0000f063'
ICON_DIVERGED=$'\U0000f00d'
ICON_UPTODATE=$'\U0000f00c'
ICON_STASHED=$'\U0000f0c9'
ICON_RENAMED=$'\U0000f178'
ICON_MODIFIED=$'\U0000f040'

# Directory segment - mirrors starship [directory]: inside a git repo, path
# is relative to the repo root (anchored on the repo name); otherwise ~ is
# substituted for $HOME. Either way, truncated to the last 3 components.
# Read-only lock appended when unwritable.
toplevel=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
if [ -n "$toplevel" ]; then
  reponame=$(basename "$toplevel")
  relpath="${cwd#"$toplevel"}"
  relpath="${relpath#/}"
  rel="$reponame${relpath:+/$relpath}"
else
  rel="$cwd"
  case "$cwd" in
    "$HOME") rel="~" ;;
    "$HOME"/*) rel="~${cwd#"$HOME"}" ;;
  esac
fi
IFS='/' read -ra parts <<< "$rel"
components=()
for p in "${parts[@]}"; do
  [ -n "$p" ] && components+=("$p")
done
count=${#components[@]}
if [ "$count" -gt 3 ]; then
  components=("${components[@]: -3}")
fi
dir_display=$(IFS=/; echo "${components[*]}")

dir_segment="${YELLOW}${dir_display}${RESET}"
if [ ! -w "$cwd" ]; then
  dir_segment="${dir_segment} ${BRIGHT_RED}${ICON_LOCK}${RESET}"
fi

# Git segment - mirrors starship [git_branch] + [git_status]
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
    ahead=0
    behind=0
    if [ -n "$upstream" ]; then
      read -r behind ahead <<< "$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)"
    fi

    stash_count=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l)
    porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    staged=false
    modified=false
    deleted=false
    renamed=false
    untracked=false
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      x=${line:0:1}
      y=${line:1:1}
      [ "$x" = '?' ] && [ "$y" = '?' ] && untracked=true
      { [ "$x" != ' ' ] && [ "$x" != '?' ]; } && staged=true
      [ "$y" = 'M' ] && modified=true
      { [ "$x" = 'D' ] || [ "$y" = 'D' ]; } && deleted=true
      [ "$x" = 'R' ] && renamed=true
    done <<< "$porcelain"

    ahead_behind=""
    if [ -n "$upstream" ]; then
      if [ "${ahead:-0}" -gt 0 ] && [ "${behind:-0}" -gt 0 ]; then
        ahead_behind="${BOLD}${BRIGHT_RED}${ICON_DIVERGED}${RESET}"
      elif [ "${ahead:-0}" -gt 0 ]; then
        ahead_behind="${CYAN}${ICON_AHEAD}${RESET}"
      elif [ "${behind:-0}" -gt 0 ]; then
        ahead_behind="${BRIGHT_RED}${ICON_BEHIND}${RESET}"
      else
        ahead_behind="${BOLD}${CYAN}${ICON_UPTODATE}${RESET}"
      fi
    fi

    all_status=""
    [ "$stash_count" -gt 0 ] && all_status="${all_status}${ICON_STASHED}"
    $staged && all_status="${all_status}${BOLD}${CYAN}+${RESET}"
    $deleted && all_status="${all_status}${BOLD}${BRIGHT_RED}-${RESET}"
    $renamed && all_status="${all_status}${BRIGHT_YELLOW}${ICON_RENAMED}${RESET}"
    $modified && all_status="${all_status}${BRIGHT_YELLOW}${ICON_MODIFIED}${RESET}"
    $untracked && all_status="${all_status}${BRIGHT_YELLOW}?${RESET}"

    git_segment=" ${BRIGHT_CYAN}${ICON_BRANCH} ${branch}${RESET}"
    [ -n "$ahead_behind" ] && git_segment="${git_segment} ${ahead_behind}"
    [ -n "$all_status" ] && git_segment="${git_segment} ${all_status}"
  fi
fi

block_segment="${dir_segment}${git_segment}"

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

printf "%b" "${block_segment}${model_segment}${context_segment}"
