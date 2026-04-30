#!/usr/bin/env bash
set -u

LOCK_FILE="/tmp/thermal-alert-daemon.lock"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  exit 0
fi

cpu_critical_count=0
gpu_critical_count=0
cpu_last_alert=0
gpu_last_alert=0
interval=5
trigger_count=2
cooldown=120
CONFIG_FILE="$HOME/.config/thermal-alert.conf"
LOG_DIR="$HOME/.local/state/thermal-alert"
LOG_FILE="$LOG_DIR/alerts.log"
sound_mode="on"
max_log_kb=256
log_rotations=5

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    sound_mode="$(sed -n 's/^SOUND=\(on\|off\)$/\1/p' "$CONFIG_FILE" | head -n1)"
    if [[ -z "$sound_mode" ]]; then
      sound_mode="on"
    fi

    local conf_max
    conf_max="$(sed -n 's/^MAX_LOG_KB=\([0-9]\+\)$/\1/p' "$CONFIG_FILE" | head -n1)"
    if [[ -n "$conf_max" ]]; then
      max_log_kb="$conf_max"
    else
      max_log_kb=256
    fi

    local conf_keep
    conf_keep="$(sed -n 's/^LOG_ROTATIONS=\([0-9]\+\)$/\1/p' "$CONFIG_FILE" | head -n1)"
    if [[ -n "$conf_keep" ]]; then
      log_rotations="$conf_keep"
    else
      log_rotations=5
    fi
  else
    sound_mode="on"
    max_log_kb=256
    log_rotations=5
  fi
}

rotate_logs_if_needed() {
  mkdir -p "$LOG_DIR"
  [[ -f "$LOG_FILE" ]] || return

  local max_bytes=$((max_log_kb * 1024))
  local current_size
  current_size=$(wc -c <"$LOG_FILE" 2>/dev/null || echo 0)

  if (( current_size < max_bytes )); then
    return
  fi

  local i
  for ((i=log_rotations; i>=1; i--)); do
    if [[ -f "${LOG_FILE}.${i}" ]]; then
      if (( i == log_rotations )); then
        rm -f "${LOG_FILE}.${i}"
      else
        mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i + 1))"
      fi
    fi
  done

  mv "$LOG_FILE" "${LOG_FILE}.1"
}

extract_field() {
  # Extracts a JSON string value without depending on jq.
  local json="$1"
  local key="$2"
  printf '%s' "$json" | sed -n "s/.*\"${key}\":\"\([^\"]*\)\".*/\1/p"
}

extract_temp() {
  local text="$1"
  printf '%s' "$text" | grep -oE '[0-9]+' | head -n1
}

play_alert_sound() {
  if [[ "$sound_mode" != "on" ]]; then
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

notify_critical() {
  local label="$1"
  local temp="$2"
  mkdir -p "$LOG_DIR"
  rotate_logs_if_needed
  printf '%s level=critical sensor=%s temp=%s sound=%s\n' "$(date '+%F %T')" "$label" "$temp" "$sound_mode" >>"$LOG_FILE"
  notify-send -u critical -a "Thermal Watch" "$label critique" "${label}: ${temp}C depuis au moins 10 secondes"
  play_alert_sound
}

while true; do
  load_config
  now=$(date +%s)

  cpu_json="$($HOME/.config/waybar/scripts/cputemp.sh 2>/dev/null || echo '{"text":" n/a","class":"na"}')"
  gpu_json="$($HOME/.config/waybar/scripts/gputemp.sh 2>/dev/null || echo '{"text":"󰢮 n/a","class":"na"}')"

  cpu_class="$(extract_field "$cpu_json" "class")"
  gpu_class="$(extract_field "$gpu_json" "class")"
  cpu_temp="$(extract_temp "$(extract_field "$cpu_json" "text")")"
  gpu_temp="$(extract_temp "$(extract_field "$gpu_json" "text")")"

  if [[ "$cpu_class" == "critical" ]]; then
    cpu_critical_count=$((cpu_critical_count + 1))
    if (( cpu_critical_count >= trigger_count )) && (( now - cpu_last_alert >= cooldown )); then
      notify_critical "CPU" "${cpu_temp:-?}"
      cpu_last_alert=$now
    fi
  else
    cpu_critical_count=0
  fi

  if [[ "$gpu_class" == "critical" ]]; then
    gpu_critical_count=$((gpu_critical_count + 1))
    if (( gpu_critical_count >= trigger_count )) && (( now - gpu_last_alert >= cooldown )); then
      notify_critical "GPU" "${gpu_temp:-?}"
      gpu_last_alert=$now
    fi
  else
    gpu_critical_count=0
  fi

  sleep "$interval"
done
