#!/usr/bin/env bash
# Desktop Health Check - Unified diagnostic tool with security audit
# Validates: Hyprland IPC, systemd services, key processes, thermal log, file permissions
# Usage: desktop-healthcheck.sh [--json] [--notify]

set -u

ok_count=0
warn_count=0
fail_count=0
json_mode=false
notify_mode=false
checks_json="[]"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json)
      json_mode=true
      shift
      ;;
    --notify)
      notify_mode=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Terminal output helpers
print_ok() {
  if [[ "$json_mode" == "false" ]]; then
    printf '[OK]   %s\n' "$1"
  fi
  ok_count=$((ok_count + 1))
  add_json_check "ok" "$1" "${2:-}"
}

print_warn() {
  if [[ "$json_mode" == "false" ]]; then
    printf '[WARN] %s\n' "$1"
  fi
  warn_count=$((warn_count + 1))
  add_json_check "warn" "$1" "${2:-}"
}

print_fail() {
  if [[ "$json_mode" == "false" ]]; then
    printf '[FAIL] %s\n' "$1"
  fi
  fail_count=$((fail_count + 1))
  add_json_check "fail" "$1" "${2:-}"
}

print_detail() {
  if [[ "$json_mode" == "false" ]]; then
    printf '       %s\n' "$1"
  fi
}

# Add check to JSON array
add_json_check() {
  local status=$1
  local check=$2
  local detail=$3
  if [[ "$json_mode" == "true" ]]; then
    local entry=$(printf '{"check":"%s","status":"%s","details":"%s"}' \
      "$(echo "$check" | sed 's/"/\\"/g')" \
      "$status" \
      "$(echo "$detail" | sed 's/"/\\"/g')")
    checks_json=$(echo "$checks_json" | jq --argjson item "$entry" '. += [$item]' 2>/dev/null || echo "[]")
  fi
}

check_user_service() {
  local service="$1"
  if systemctl --user --quiet is-active "$service"; then
    print_ok "$service is active"
  else
    print_fail "$service is not active"
  fi
}

check_process() {
  local name="$1"
  if pgrep -x "$name" >/dev/null 2>&1; then
    print_ok "$name process is running"
  else
    print_warn "$name process is not running"
  fi
}

# Security audit: Check file permissions
check_file_security() {
  local filepath=$1
  local check_name=$2
  
  if [[ ! -e "$filepath" ]]; then
    print_warn "Security: $check_name" "(file not found)"
    return
  fi
  
  # Get file owner and permissions
  local perms=$(stat -c '%a' "$filepath" 2>/dev/null || stat -f '%A' "$filepath" 2>/dev/null || echo "unknown")
  local owner=$(stat -c '%U' "$filepath" 2>/dev/null || stat -f '%Su' "$filepath" 2>/dev/null || echo "unknown")
  
  # Check if world-writable (security risk: last digit is 6 or 7, or middle digit is 3,6,7)
  local last_digit=${perms: -1}
  local middle_digit=${perms:1:1}
  
  if [[ "$last_digit" == "6" ]] || [[ "$last_digit" == "7" ]] || \
     [[ "$middle_digit" == "6" ]] || [[ "$middle_digit" == "7" ]]; then
    print_fail "Security: $check_name" "world-writable ($perms), owner: $owner"
  elif [[ "$owner" != "adeline" ]]; then
    print_warn "Security: $check_name" "owner not adeline: $owner"
  else
    print_ok "Security: $check_name" "secure ($perms), owner: $owner"
  fi
}

# Terminal header (only in non-JSON mode)
if [[ "$json_mode" == "false" ]]; then
  echo '=== Desktop Healthcheck ==='
  printf 'Time: %s\n' "$(date '+%F %T')"
  echo
fi

# 1. Hyprland IPC responsive
if command -v hyprctl >/dev/null 2>&1; then
  if hyprctl monitors >/dev/null 2>&1; then
    monitor_count=$(hyprctl -j monitors 2>/dev/null | jq 'length' 2>/dev/null || echo '?')
    print_ok "Hyprland IPC responsive" "(monitors: $monitor_count)"
  else
    print_fail 'Hyprland IPC not responsive'
  fi
else
  print_fail 'hyprctl command not found'
fi

# 2-3. Systemd user services
check_user_service waybar.service
check_user_service thermal-alert.service

# 4-6. Key processes
check_process hypridle
check_process mako
check_process waybar

# 7. Thermal log present and recent
if [[ -f "$HOME/.local/state/thermal-alert/alerts.log" ]]; then
  last_alert=$(tail -n 1 "$HOME/.local/state/thermal-alert/alerts.log" 2>/dev/null || true)
  if [[ -n "$last_alert" ]]; then
    print_ok "thermal log available"
    print_detail "last thermal log: $last_alert"
  else
    print_warn 'thermal log file exists but is empty'
  fi
else
  print_warn 'thermal log file does not exist yet'
fi

# 8-11. Security audit checks
check_file_security "$HOME/.config/bin/desktop-healthcheck.sh" "healthcheck script"
check_file_security "$HOME/.config/bin/thermal-alert-daemon.sh" "thermal daemon"
check_file_security "$HOME/.config/thermal-alert.conf" "thermal config"
check_file_security "$HOME/.config/systemd/user/thermal-alert.service" "systemd service"

# Terminal summary (only in non-JSON mode)
if [[ "$json_mode" == "false" ]]; then
  echo
  printf 'Summary: ok=%d warn=%d fail=%d\n' "$ok_count" "$warn_count" "$fail_count"
fi

# JSON output mode
if [[ "$json_mode" == "true" ]]; then
  output=$(jq -n \
    --arg timestamp "$(date -Iseconds)" \
    --argjson checks "$checks_json" \
    --arg ok "$ok_count" \
    --arg warn "$warn_count" \
    --arg fail "$fail_count" \
    '{timestamp: $timestamp, checks: $checks, summary: {ok: ($ok | tonumber), warn: ($warn | tonumber), fail: ($fail | tonumber)}}' 2>/dev/null)
  echo "$output"
fi

# Auto-notification on FAIL (if requested)
if [[ "$notify_mode" == "true" ]] && (( fail_count > 0 )); then
  notify-send -u critical "Desktop Health Check" "FAIL: $fail_count check(s) failed. Run 'dcheck' for details."
fi

# Exit with non-zero if any failures
if (( fail_count > 0 )); then
  exit 1
fi

exit 0
