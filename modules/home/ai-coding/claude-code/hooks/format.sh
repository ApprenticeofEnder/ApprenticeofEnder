#!/usr/bin/env bash

set -euo pipefail

FILE_PATH=$(cat | jq -r '.tool_input.file_path')

if echo "$FILE_PATH" | rg '\.(jsx?|tsx?|html|jsonc?|vue|css|md|yaml)$' --quiet; then
  bunx prettier --write "$FILE_PATH" 2>/dev/null
  exit 0
fi

if echo "$FILE_PATH" | rg '\.(py|ipynb)$' --quiet; then
  ruff format "$FILE_PATH" 2>/dev/null
  exit 0
fi
