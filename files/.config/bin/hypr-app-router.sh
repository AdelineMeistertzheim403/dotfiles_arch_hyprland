#!/usr/bin/env bash
# Route common apps to a predictable monitor/workspace layout.

set -euo pipefail

focused_monitor() {
  hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name' | head -n1
}

focused_workspace() {
  hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .activeWorkspace.id' | head -n1
}

left_monitor() {
  hyprctl -j monitors | jq -r 'sort_by(.x) | .[0].name'
}

right_monitor() {
  hyprctl -j monitors | jq -r 'sort_by(.x) | .[-1].name'
}

laptop_monitor() {
  local laptop
  laptop="$(hyprctl -j monitors | jq -r '.[] | select(.name == "eDP-1") | .name' | head -n1)"
  if [[ -n "$laptop" ]]; then
    echo "$laptop"
  else
    focused_monitor
  fi
}

monitor_active_workspace() {
  local monitor="$1"
  hyprctl -j monitors | jq -r --arg monitor "$monitor" '.[] | select(.name == $monitor) | .activeWorkspace.id' | head -n1
}

dispatch_workspace() {
  local workspace="$1"
  hyprctl dispatch workspace "$workspace" >/dev/null 2>&1 || true
}

move_active_to_screen() {
  local target="$1"
  local monitor workspace

  case "$target" in
    left)
      monitor="$(left_monitor)"
      ;;
    laptop)
      monitor="$(laptop_monitor)"
      ;;
    right)
      monitor="$(right_monitor)"
      ;;
    *)
      echo "Usage: $0 move-active [left|laptop|right]" >&2
      exit 1
      ;;
  esac

  workspace="$(monitor_active_workspace "$monitor")"
  [[ -n "$workspace" ]] || exit 1
  hyprctl dispatch movetoworkspacesilent "$workspace" >/dev/null
  notify-send "Fenêtre déplacée" "→ $target ($monitor)" -t 2000
}

launch_browser() {
  dispatch_workspace 2
  nohup firefox >/dev/null 2>&1 &
}

launch_code() {
  dispatch_workspace 3
  nohup code >/dev/null 2>&1 &
}

launch_chat() {
  dispatch_workspace 4
  nohup discord >/dev/null 2>&1 &
}

launch_terminal() {
  dispatch_workspace "$(focused_workspace)"
  nohup kitty >/dev/null 2>&1 &
}

launch_files() {
  dispatch_workspace "$(focused_workspace)"
  nohup nautilus >/dev/null 2>&1 &
}

case "${1:-}" in
  browser)
    launch_browser
    ;;
  code)
    launch_code
    ;;
  chat)
    launch_chat
    ;;
  terminal)
    launch_terminal
    ;;
  files)
    launch_files
    ;;
  move-active)
    move_active_to_screen "${2:-}"
    ;;
  focused-monitor)
    focused_monitor
    ;;
  *)
    echo "Usage: $0 [browser|code|chat|terminal|files|move-active|focused-monitor]" >&2
    exit 1
    ;;
esac