#!/usr/bin/env bash
set -u

temp=""

if command -v nvidia-smi >/dev/null 2>&1; then
  temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -dc '0-9')
fi

if [[ -z "$temp" ]] && command -v sensors >/dev/null 2>&1; then
  temp=$(sensors 2>/dev/null | awk '
    /edge:|junction:|GPU|amdgpu|nouveau|temp1:/ {
      if (match($0, /[-+]?[0-9]+(\.[0-9]+)?°C/)) {
        t = substr($0, RSTART, RLENGTH)
        gsub(/[+°C]/, "", t)
        printf "%d\n", (t + 0.5)
        exit
      }
    }
  ')
fi

if [[ -z "$temp" ]]; then
  max_milli=0
  for sensor in /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input; do
    [[ -r "$sensor" ]] || continue
    value=$(cat "$sensor" 2>/dev/null || echo 0)
    [[ "$value" =~ ^[0-9]+$ ]] || continue
    if (( value > max_milli )); then
      max_milli=$value
    fi
  done
  if (( max_milli > 0 )); then
    temp=$((max_milli / 1000))
  fi
fi

if [[ -z "$temp" ]]; then
  printf '{"text":"󰢮 n/a","class":"na"}\n'
  exit 0
fi

class="cool"
if (( temp >= 90 )); then
  class="critical"
elif (( temp >= 82 )); then
  class="hot"
elif (( temp >= 68 )); then
  class="warm"
fi

printf '{"text":"󰢮 %s°C","class":"%s"}\n' "$temp" "$class"
