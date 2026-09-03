#!/bin/bash
# Claude Code status line.
# Directory/git segments mirror the Starship config at ~/.config/starship.toml
# (dark palette, powerline-style background block). No end-cap glyph: the
# terminal font doesn't render U+E0B0, so Starship's own chevron is equally
# invisible there. Model name and context-remaining segments are Claude Code
# additions with no Starship equivalent, so they're plain colored text after
# the block.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

RESET=$'\033[0m'
BG=$'\033[48;2;60;56;54m'
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
ICON_AHEAD=$'\U000f4f2'
ICON_BEHIND=$'\U000f4ef'
# Plain Unicode symbols (✔ ✗ ≡ » ≠) are ambiguous-width in this font and end
# up half-painted against the single-width background fill; these Nerd Font
# PUA glyphs are pinned single-width like the branch/lock icons above.
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

dir_segment="${BG}${YELLOW}${dir_display}${RESET}"
if [ ! -w "$cwd" ]; then
  dir_segment="${dir_segment}${BG} ${BRIGHT_RED}${ICON_LOCK}${RESET}"
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
        ahead_behind="${BOLD}${BRIGHT_RED}${ICON_DIVERGED}${RESET}${BG}"
      elif [ "${ahead:-0}" -gt 0 ]; then
        ahead_behind="${CYAN}${ICON_AHEAD}${RESET}${BG}"
      elif [ "${behind:-0}" -gt 0 ]; then
        ahead_behind="${BRIGHT_RED}${ICON_BEHIND}${RESET}${BG}"
      else
        ahead_behind="${BOLD}${CYAN}${ICON_UPTODATE}${RESET}${BG}"
      fi
    fi

    all_status=""
    [ "$stash_count" -gt 0 ] && all_status="${all_status}${ICON_STASHED}"
    $staged && all_status="${all_status}${BOLD}${CYAN}+${RESET}${BG}"
    $deleted && all_status="${all_status}${BOLD}${BRIGHT_RED}-${RESET}${BG}"
    $renamed && all_status="${all_status}${BRIGHT_YELLOW}${ICON_RENAMED}${RESET}${BG}"
    $modified && all_status="${all_status}${BRIGHT_YELLOW}${ICON_MODIFIED}${RESET}${BG}"
    $untracked && all_status="${all_status}${BRIGHT_YELLOW}?${RESET}${BG}"

    git_segment="${BG} ${BRIGHT_CYAN}${ICON_BRANCH} ${branch}${RESET}${BG}"
    [ -n "$ahead_behind" ] && git_segment="${git_segment} ${ahead_behind}"
    [ -n "$all_status" ] && git_segment="${git_segment} ${all_status}"
  fi
fi

block_segment="${dir_segment}${git_segment}${RESET}"

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
