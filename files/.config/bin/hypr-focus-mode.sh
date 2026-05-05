#!/usr/bin/env bash
# Visual mode manager for Hyprland.
# Modes: normal, focus, gaming, stream, presentation.
# Auto mode: stream when OBS is running, gaming when a fullscreen game is detected.

set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-visual-mode.state"
AUTO_PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-visual-mode.pid"

notify() {
  local msg="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprland" "$msg"
  fi
}

stop_presentation_services() {
  systemctl --user stop waybar.service >/dev/null 2>&1 || pkill -x waybar >/dev/null 2>&1 || true
  pkill -x mako >/dev/null 2>&1 || true
  # Couper quickshell (spotlight launcher)
  pkill -x qs >/dev/null 2>&1 || true
}

start_presentation_services() {
  systemctl --user restart waybar.service >/dev/null 2>&1 || nohup waybar >/dev/null 2>&1 &
  if command -v mako >/dev/null 2>&1 && ! pgrep -x mako >/dev/null 2>&1; then
    nohup mako >/dev/null 2>&1 &
  fi
  # Relancer quickshell
  if command -v qs >/dev/null 2>&1 && ! pgrep -x qs >/dev/null 2>&1; then
    nohup qs -c spotlight >/dev/null 2>&1 &
  fi
}

write_mode() {
  printf '%s\n' "$1" >"$STATE_FILE"
}

current_mode() {
  if [[ -f "$STATE_FILE" ]]; then
    tr -d '\n' <"$STATE_FILE"
  else
    echo "normal"
  fi
}

apply_normal_mode() {
  hyprctl keyword decoration:inactive_opacity 0.94 >/dev/null
  hyprctl keyword decoration:shadow:range 16 >/dev/null
  hyprctl keyword decoration:blur:size 12 >/dev/null
  hyprctl keyword decoration:blur:vibrancy 0.35 >/dev/null
  hyprctl keyword general:gaps_in 8 >/dev/null
  hyprctl keyword general:gaps_out 16 >/dev/null
  hyprctl keyword animations:enabled true >/dev/null
}

apply_focus_mode() {
  hyprctl keyword decoration:inactive_opacity 0.82 >/dev/null
  hyprctl keyword decoration:shadow:range 7 >/dev/null
  hyprctl keyword decoration:blur:size 7 >/dev/null
  hyprctl keyword decoration:blur:vibrancy 0.10 >/dev/null
  hyprctl keyword general:gaps_in 5 >/dev/null
  hyprctl keyword general:gaps_out 10 >/dev/null
  hyprctl keyword animations:enabled true >/dev/null
}

apply_gaming_mode() {
  hyprctl keyword decoration:inactive_opacity 0.98 >/dev/null
  hyprctl keyword decoration:shadow:range 0 >/dev/null
  hyprctl keyword decoration:blur:size 4 >/dev/null
  hyprctl keyword decoration:blur:vibrancy 0.00 >/dev/null
  hyprctl keyword general:gaps_in 2 >/dev/null
  hyprctl keyword general:gaps_out 4 >/dev/null
  hyprctl keyword animations:enabled false >/dev/null
}

apply_stream_mode() {
  hyprctl keyword decoration:inactive_opacity 0.90 >/dev/null
  hyprctl keyword decoration:shadow:range 10 >/dev/null
  hyprctl keyword decoration:blur:size 9 >/dev/null
  hyprctl keyword decoration:blur:vibrancy 0.15 >/dev/null
  hyprctl keyword general:gaps_in 6 >/dev/null
  hyprctl keyword general:gaps_out 12 >/dev/null
  hyprctl keyword animations:enabled true >/dev/null
}

apply_presentation_mode() {
  hyprctl keyword decoration:active_opacity 1.00 >/dev/null
  hyprctl keyword decoration:inactive_opacity 1.00 >/dev/null
  hyprctl keyword decoration:shadow:range 6 >/dev/null
  hyprctl keyword decoration:blur:size 2 >/dev/null
  hyprctl keyword decoration:blur:vibrancy 0.00 >/dev/null
  hyprctl keyword general:gaps_in 10 >/dev/null
  hyprctl keyword general:gaps_out 18 >/dev/null
  hyprctl keyword animations:enabled false >/dev/null
}

set_mode() {
  local mode="$1"
  local previous_mode
  previous_mode="$(current_mode)"

  case "$mode" in
    normal)
      apply_normal_mode
      if [[ "$previous_mode" == "presentation" ]]; then
        start_presentation_services
      fi
      write_mode normal
      notify "Mode normal actif"
      ;;
    focus)
      apply_focus_mode
      if [[ "$previous_mode" == "presentation" ]]; then
        start_presentation_services
      fi
      write_mode focus
      notify "Mode focus actif"
      ;;
    gaming)
      apply_gaming_mode
      if [[ "$previous_mode" == "presentation" ]]; then
        start_presentation_services
      fi
      write_mode gaming
      notify "Mode gaming actif"
      ;;
    stream)
      apply_stream_mode
      if [[ "$previous_mode" == "presentation" ]]; then
        start_presentation_services
      fi
      write_mode stream
      notify "Mode stream actif"
      ;;
    presentation)
      apply_presentation_mode
      stop_presentation_services
      write_mode presentation
      notify "Mode presentation actif"
      ;;
    *)
      echo "Usage: $0 [toggle|normal|focus|gaming|stream|presentation|presentation-toggle|status|auto-start|auto-stop|auto-toggle|auto-status]" >&2
      exit 1
      ;;
  esac
}

is_obs_running() {
  pgrep -x obs >/dev/null 2>&1 || pgrep -f obs >/dev/null 2>&1
}

is_fullscreen_game_present() {
  hyprctl -j clients 2>/dev/null | jq -e '
    map(select(.fullscreen == true))
    | map(select((.class // "") | test("(?i)(steam|gamescope|lutris|heroic|bottles|wine|proton|cs2|dota|elden|overwatch|minecraft)")))
    | length > 0
  ' >/dev/null 2>&1
}

auto_mode_target() {
  if is_obs_running; then
    echo stream
    return
  fi
  if is_fullscreen_game_present; then
    echo gaming
    return
  fi
  echo normal
}

auto_loop() {
  echo "$$" >"$AUTO_PID_FILE"
  while true; do
    local target
    if [[ "$(current_mode)" == "presentation" ]]; then
      sleep 6
      continue
    fi
    target="$(auto_mode_target)"
    if [[ "$(current_mode)" != "$target" ]]; then
      set_mode "$target"
    fi
    sleep 6
  done
}

auto_running() {
  [[ -f "$AUTO_PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$AUTO_PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

start_auto() {
  if auto_running; then
    return
  fi
  nohup bash "$0" auto-loop >/dev/null 2>&1 &
  notify "Auto mode active"
}

stop_auto() {
  if auto_running; then
    kill "$(cat "$AUTO_PID_FILE")" >/dev/null 2>&1 || true
    rm -f "$AUTO_PID_FILE"
    notify "Auto mode desactive"
  fi
}

command="${1:-toggle}"
case "$command" in
  toggle)
    if [[ "$(current_mode)" == "focus" ]]; then
      set_mode normal
    else
      set_mode focus
    fi
    ;;
  normal|focus|gaming|stream|presentation)
    set_mode "$command"
    ;;
  presentation-toggle)
    if [[ "$(current_mode)" == "presentation" ]]; then
      set_mode normal
    else
      set_mode presentation
    fi
    ;;
  status)
    echo "$(current_mode)"
    ;;
  auto-loop)
    auto_loop
    ;;
  auto-start)
    start_auto
    ;;
  auto-stop)
    stop_auto
    ;;
  auto-toggle)
    if auto_running; then
      stop_auto
    else
      start_auto
    fi
    ;;
  auto-status)
    if auto_running; then
      echo enabled
    else
      echo disabled
    fi
    ;;
  *)
    echo "Usage: $0 [toggle|normal|focus|gaming|stream|presentation|presentation-toggle|status|auto-start|auto-stop|auto-toggle|auto-status]" >&2
    exit 1
    ;;
esac
