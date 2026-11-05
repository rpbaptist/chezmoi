#!/usr/bin/env bash
# Open the Ctrl+clicked URL in terminal-browser. Reuse the browser in the
# current herdr tab; else open a new browser in a right split.
set -euo pipefail

url=${HERDR_PLUGIN_CLICKED_URL:?HERDR_PLUGIN_CLICKED_URL is not set}

if ! command -v terminal-browser >/dev/null 2>&1; then
  xdg-open "$url"
  exit
fi

# new-tab fails when the tab has more than one browser.
terminal-browser new-tab "$url" </dev/null ||
  exec terminal-browser open "$url" --split right </dev/null
