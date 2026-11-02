# Input: the managed base settings. $cur: the current target file.
# Copy each hook group that Orca installed from $cur into the base, so
# chezmoi does not remove the hooks that Orca writes on each start.
def orca: tostring | test("\\.orca/agent-hooks|ORCA_");

($cur.hooks // {} | map_values(map(select(orca))) | with_entries(select(.value | length > 0))) as $orca
| .hooks = reduce ($orca | to_entries[]) as $e (.hooks // {};
    .[$e.key] = ((.[$e.key] // []) + $e.value))
