#!/usr/bin/env bash
set -u

temp=""

if command -v sensors >/dev/null 2>&1; then
  temp=$(sensors 2>/dev/null | awk '
    /Package id 0:|Tctl:|Tdie:|CPU Temperature:|temp1:/ {
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
  for zone in /sys/class/thermal/thermal_zone*/temp; do
    [[ -r "$zone" ]] || continue
    value=$(cat "$zone" 2>/dev/null || echo 0)
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
  printf '{"text":" n/a","class":"na"}\n'
  exit 0
fi

class="cool"
if (( temp >= 90 )); then
  class="critical"
elif (( temp >= 80 )); then
  class="hot"
elif (( temp >= 65 )); then
  class="warm"
fi

printf '{"text":" %s°C","class":"%s"}\n' "$temp" "$class"
