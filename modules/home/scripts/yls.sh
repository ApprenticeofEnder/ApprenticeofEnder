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
    brew list 2>/dev/null | rg -i "$TARGET"
    divider
    return
  fi

  if [ "$PROGRAM" == "apt" ]; then
    apt list --installed 2>/dev/null | rg -i "$TARGET"
    divider
    return
  fi

  if [ "$PROGRAM" == "yay" ]; then
    yay -Qqe 2>/dev/null | rg -i "$TARGET"
    divider
    return
  fi

  if [ "$PROGRAM" == "flatpak" ]; then
    flatpak list 2>/dev/null | rg -i "$TARGET"
    return
  fi

  "$PROGRAM" "$TARGET"

  divider
}

TARGET="$1"

PROGRAMS=(
  "which"
  "where"
  "whereis"
  "brew"
  "apt"
  "yay"
  "flatpak"
)
for program in "${PROGRAMS[@]}"; do
  try "$program" "$TARGET"
done
