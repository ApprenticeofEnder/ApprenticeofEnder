#!/usr/bin/env bash

set -euo pipefail

REPO="${1:-}"

if [ -z "$REPO" ]; then
  echo "Usage: sha-pinning-md.sh <REPO>"
  echo "Note: <REPO> should be in full OWNER/REPO format."
  exit 1
fi

GH=$(which gh)
TAGS=$("$GH" release list -R "$REPO" --json 'tagName' --jq 'sort_by(.tagName) | reverse | .[].tagName')

for TAG in $TAGS; do
  git ls-remote "https://github.com/$REPO" "$TAG"
done
