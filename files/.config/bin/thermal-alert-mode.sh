#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/thermal-alert.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'SOUND=on\n' >"$CONFIG_FILE"
fi

current="$(sed -n 's/^SOUND=\(on\|off\)$/\1/p' "$CONFIG_FILE" | head -n1)"
if [[ -z "$current" ]]; then
  current="on"
fi

action="${1:-status}"
next="$current"

case "$action" in
  on)
    next="on"
    ;;
  off)
    next="off"
    ;;
  toggle)
    if [[ "$current" == "on" ]]; then
      next="off"
    else
      next="on"
    fi
    ;;
  status)
    ;;
  *)
    echo "Usage: $0 [on|off|toggle|status]"
    exit 1
    ;;
esac

if [[ "$action" != "status" ]]; then
  printf '# Thermal alert preferences\nSOUND=%s\n' "$next" >"$CONFIG_FILE"
fi

echo "Thermal alert sound: $next"
