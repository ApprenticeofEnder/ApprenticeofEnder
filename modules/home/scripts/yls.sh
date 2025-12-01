function divider() {
  echo "---------------------------------------"
}

function try() {
  PROGRAM="$1"
  TARGET="$2"

  echo "Trying '$PROGRAM' on '$TARGET'..."

  if [ "$PROGRAM" == "where" ]; then
    type -a "$TARGET"
    divider
    return
  fi

  if ! command -v "$PROGRAM" >/dev/null 2>&1; then
    echo "$PROGRAM not found on this system." >&2
    divider
    return
  fi

  if [ "$PROGRAM" == "brew" ]; then
    brew list | grep "$TARGET"
    divider
    return
  fi

  if [ "$PROGRAM" == "apt" ]; then
    apt list --installed | grep "$TARGET"
    divider
    return
  fi

  if [ "$PROGRAM" == "yay" ]; then
    yay -Qqe | grep "$TARGET"
    divider
    return
  fi

  "$PROGRAM" "$TARGET"

  divider
}

TARGET="$1"

try which "$TARGET"

try where "$TARGET"

try whereis "$TARGET"

try brew "$TARGET"

try apt "$TARGET"

try yay "$TARGET"
