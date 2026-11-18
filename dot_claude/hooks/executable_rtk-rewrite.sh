#!/usr/bin/env bash
# Run `rtk hook claude`, except in auto mode.
#
# Auto mode reviews a Bash call before PreToolUse hooks run. When the rtk
# hook rewrites the command, the review no longer covers it, and Claude Code
# denies the call ("a hook changed this call's input after auto mode reviewed
# it"). In auto mode, pass the command through unchanged; the agent prefixes
# `rtk` itself, so the classifier sees the real command.

input=$(cat)
[ "$(jq -r '.permission_mode // empty' <<<"$input")" = "auto" ] && exit 0
exec rtk hook claude <<<"$input"
