#!/usr/bin/env bash
# Popup for the prefix+ctrl+a leader key. Read one key, then open a pane that
# runs Claude in the session cwd of the focused pane (see split-follow.sh).
set -euo pipefail

printf '  Claude\n\n  |  split right\n  -  split down\n  n  new tab\n'
IFS= read -rsn1 key

split=$HOME/.config/herdr/scripts/split-follow.sh
case $key in
  '|') exec "$split" right claude ;;
  -) exec "$split" down claude ;;
  n) exec "$split" tab claude ;;
esac
