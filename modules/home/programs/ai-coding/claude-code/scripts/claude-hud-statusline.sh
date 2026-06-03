#!/usr/bin/env bash
# StatusLine command for claude-hud plugin.
#
# Resolves the highest-semver claude-hud plugin directory, sets COLUMNS from
# the current terminal width, then execs node with the plugin's entry point.
set -euo pipefail

# Terminal width minus 4 for padding; fall back to 120 if stty fails.
cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
export COLUMNS=$((${cols:-120} > 4 ? ${cols:-120} - 4 : 1))

# Find the latest semver-versioned claude-hud plugin directory.
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
plugin_dir=$(
  find "$config_dir/plugins/cache" -mindepth 3 -maxdepth 3 -type d -path "*/claude-hud/*" 2>/dev/null |
    awk -F/ '{ print $(NF-1) "\t" $0 }' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+[[:space:]]' |
    sort -t. -k1,1n -k2,2n -k3,3n -k4,4n |
    tail -1 |
    cut -f2-
)

exec node "${plugin_dir}/dist/index.js"
