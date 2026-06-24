#!/usr/bin/env bash
# PreToolUse hook — clamp the Bash tool's `timeout` parameter to 30 seconds.
# Background commands are exempt (they are meant to run long).
#
# Reads the PreToolUse JSON payload on stdin, emits a hookSpecificOutput JSON
# response that allows the call with an updatedToolInput merging in the
# clamped timeout.
set -euo pipefail

CEILING_MS=30000

input="$(cat)"
tool_name="$(jq -r '.tool_name // ""' <<<"$input")"

allow_unchanged() {
    printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
}

[ "$tool_name" = "Bash" ] || allow_unchanged

run_in_background="$(jq -r '.tool_input.run_in_background // false' <<<"$input")"
[ "$run_in_background" = "true" ] && allow_unchanged

requested="$(jq -r ".tool_input.timeout // $CEILING_MS" <<<"$input")"
if [ "$requested" -le "$CEILING_MS" ]; then
    clamped="$requested"
else
    clamped="$CEILING_MS"
fi

jq --argjson t "$clamped" --argjson req "$requested" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: ("Bash timeout clamped to " + ($t|tostring) + "ms (requested " + ($req|tostring) + "ms). Hard ceiling: 30s. If the command times out, the Bash tool will report \"Command timed out after " + ($t|tostring) + " ms\" — split it, run it in the background with run_in_background=true, or shorten it."),
        updatedToolInput: (.tool_input + {timeout: $t})
    }
}' <<<"$input"
