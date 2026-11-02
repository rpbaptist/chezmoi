#!/usr/bin/env bash
# Set the herdr pane title to the issue an agent works on.
#
# UserPromptSubmit: `/implement #10` or `/implement <url>/10` reports "#10"
# at once, then "#10 <issue title>" when gh can fetch the title. The same
# applies to /implement-spec, /to-spec, the grill skills and the review skills.
# SessionStart (clear): remove the title, so the tab follows the new session.
#
# herdr-auto-title ranks the pane title above the terminal title, so the
# issue stays in the tab name while Claude Code renames its session.

[ "${HERDR_ENV:-}" = "1" ] && [ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null && command -v jq >/dev/null || exit 0

source_id="user:issue-title"
input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input")

report() {
  herdr pane report-metadata "$HERDR_PANE_ID" --source "$source_id" \
    --agent claude --seq "$(date +%s%N)" "$@" >/dev/null 2>&1
}

if [ "$event" = "SessionStart" ]; then
  [ "$(jq -r '.source // empty' <<<"$input")" = "clear" ] && report --clear-title
  exit 0
fi

[ "$event" = "UserPromptSubmit" ] || exit 0

prompt=$(jq -r '.prompt // empty' <<<"$input")
# An optional plugin prefix, such as /mattpocock-skills:grilling.
skills='implement|implement-spec|to-spec|grill[a-z-]*|[a-z-]*review'
re="^[[:space:]]*/([a-z0-9_-]+:)?($skills)[[:space:]]+([^[:space:]]+)"
[[ $prompt =~ $re ]] || exit 0
ref=${BASH_REMATCH[3]}

# Only an issue reference: #10, 10 or a URL that ends in /10.
[[ $ref =~ ^#?([0-9]+)$ || $ref =~ ^https?://.*/([0-9]+)/?$ ]] || exit 0
number=${BASH_REMATCH[1]}

report --title "#$number"

command -v gh >/dev/null || exit 0
cwd=$(jq -r '.cwd // empty' <<<"$input")

# Fetch the title in the background, so the prompt does not wait for gh.
(
  cd "${cwd:-.}" || exit 0
  case $ref in
    */pull/*) kinds="pr" ;;
    http*) kinds="issue" ;;
    *) ref=$number kinds="issue pr" ;;
  esac
  for kind in $kinds; do
    title=$(timeout 10 gh "$kind" view "$ref" --json title -q .title 2>/dev/null)
    [ -n "$title" ] && report --title "#$number $title" && exit 0
  done
) </dev/null >/dev/null 2>&1 &
disown

exit 0
