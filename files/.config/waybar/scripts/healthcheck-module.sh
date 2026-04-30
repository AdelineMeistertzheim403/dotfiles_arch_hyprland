#!/usr/bin/env bash
# Waybar Health Check Module - JSON output for custom module
# Displays: ok/warn/fail counts with icon and color

# Get healthcheck results in JSON format
healthcheck_json=$($HOME/.config/bin/desktop-healthcheck.sh --json 2>/dev/null)

# Parse the JSON to extract summary
ok=$(echo "$healthcheck_json" | jq '.summary.ok' 2>/dev/null || echo "?")
warn=$(echo "$healthcheck_json" | jq '.summary.warn' 2>/dev/null || echo "?")
fail=$(echo "$healthcheck_json" | jq '.summary.fail' 2>/dev/null || echo "?")

# Determine icon and class based on status
if [[ "$fail" != "0" ]] && [[ "$fail" != "?" ]]; then
  icon="⚠️"
  class="critical"
  text="$fail fail"
elif [[ "$warn" != "0" ]] && [[ "$warn" != "?" ]]; then
  icon="⚡"
  class="warning"
  text="$warn warn"
else
  icon="✓"
  class="ok"
  text="ok"
fi

# Output for Waybar custom module JSON format
jq -n \
  --arg text "$text" \
  --arg tooltip "Desktop Health: ok=$ok warn=$warn fail=$fail" \
  --arg class "$class" \
  --arg icon "$icon" \
  '{text: ($icon + " " + $text), tooltip: $tooltip, class: $class, alt: ($class)}'
