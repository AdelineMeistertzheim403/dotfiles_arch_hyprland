#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/thermal-alert.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

SOUND="${SOUND:-on}"
TARGET="${1:-both}"
TEMP="${2:-95}"
LOG_DIR="$HOME/.local/state/thermal-alert"
LOG_FILE="$LOG_DIR/alerts.log"
MAX_LOG_KB="${MAX_LOG_KB:-256}"
LOG_ROTATIONS="${LOG_ROTATIONS:-5}"

rotate_logs_if_needed() {
  mkdir -p "$LOG_DIR"
  [[ -f "$LOG_FILE" ]] || return

  local max_bytes=$((MAX_LOG_KB * 1024))
  local current_size
  current_size=$(wc -c <"$LOG_FILE" 2>/dev/null || echo 0)

  if (( current_size < max_bytes )); then
    return
  fi

  local i
  for ((i=LOG_ROTATIONS; i>=1; i--)); do
    if [[ -f "${LOG_FILE}.${i}" ]]; then
      if (( i == LOG_ROTATIONS )); then
        rm -f "${LOG_FILE}.${i}"
      else
        mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i + 1))"
      fi
    fi
  done

  mv "$LOG_FILE" "${LOG_FILE}.1"
}

play_alert_sound() {
  if [[ "$SOUND" != "on" ]]; then
    return
  fi

  if command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play -i dialog-warning >/dev/null 2>&1 || true
    return
  fi

  if command -v paplay >/dev/null 2>&1; then
    local sound_file="/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
    if [[ -f "$sound_file" ]]; then
      paplay "$sound_file" >/dev/null 2>&1 || true
    fi
  fi
}

notify_one() {
  local label="$1"
  mkdir -p "$LOG_DIR"
  rotate_logs_if_needed
  printf '%s level=test sensor=%s temp=%s sound=%s\n' "$(date '+%F %T')" "$label" "$TEMP" "$SOUND" >>"$LOG_FILE"
  notify-send -u critical -a "Thermal Watch" "$label critique (test)" "${label}: ${TEMP}C pendant 10 secondes"
  play_alert_sound
}

case "$TARGET" in
  cpu)
    notify_one "CPU"
    ;;
  gpu)
    notify_one "GPU"
    ;;
  both)
    notify_one "CPU"
    notify_one "GPU"
    ;;
  *)
    echo "Usage: $0 [cpu|gpu|both] [temp]"
    exit 1
    ;;
esac

echo "Test alert sent for: $TARGET (temp=${TEMP}C, sound=${SOUND})"
