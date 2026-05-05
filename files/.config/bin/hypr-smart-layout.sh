#!/usr/bin/env bash
# Smart gaps watcher for Hyprland.

set -euo pipefail

MODE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-visual-mode.state"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-smart-layout.pid"
CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-smart-layout.cache"

current_mode() {
  if [[ -f "$MODE_FILE" ]]; then
    tr -d '\n' <"$MODE_FILE"
  else
    echo "normal"
  fi
}

base_gaps() {
  case "$(current_mode)" in
    focus)
      echo "5 10 0 6"
      ;;
    gaming)
      echo "2 4 0 2"
      ;;
    stream)
      echo "6 12 0 6"
      ;;
    presentation)
      echo "10 18 0 10"
      ;;
    *)
      echo "8 16 0 8"
      ;;
  esac
}

apply_gaps() {
  local gaps_in="$1"
  local gaps_out="$2"
  local new_state="${gaps_in}:${gaps_out}"
  local old_state=""

  if [[ -f "$CACHE_FILE" ]]; then
    old_state="$(cat "$CACHE_FILE" 2>/dev/null || true)"
  fi

  if [[ "$new_state" != "$old_state" ]]; then
    hyprctl keyword general:gaps_in "$gaps_in" >/dev/null
    hyprctl keyword general:gaps_out "$gaps_out" >/dev/null
    printf '%s\n' "$new_state" >"$CACHE_FILE"
  fi
}

refresh() {
  local info windows fullscreen base_in base_out single_in single_out
  info="$(hyprctl -j activeworkspace 2>/dev/null || echo '{}')"
  windows="$(echo "$info" | jq -r '.windows // 0')"
  fullscreen="$(echo "$info" | jq -r '.hasfullscreen // false')"
  read -r base_in base_out single_in single_out <<<"$(base_gaps)"

  if [[ "$fullscreen" == "true" ]]; then
    apply_gaps 0 0
  elif (( windows <= 1 )); then
    apply_gaps "$single_in" "$single_out"
  else
    apply_gaps "$base_in" "$base_out"
  fi
}

loop() {
  printf '%s\n' "$$" >"$PID_FILE"
  while true; do
    refresh
    sleep 2
  done
}

is_running() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

start() {
  if is_running; then
    return
  fi
  nohup bash "$0" loop >/dev/null 2>&1 &
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if is_running; then
      return
    fi
    sleep 0.1
  done
}

stop() {
  if is_running; then
    kill "$(cat "$PID_FILE")" >/dev/null 2>&1 || true
  fi
  rm -f "$PID_FILE" "$CACHE_FILE"
}

case "${1:-refresh}" in
  refresh)
    refresh
    ;;
  loop)
    loop
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    if is_running; then
      echo enabled
    else
      echo disabled
    fi
    ;;
  *)
    echo "Usage: $0 [refresh|loop|start|stop|status]" >&2
    exit 1
    ;;
esac