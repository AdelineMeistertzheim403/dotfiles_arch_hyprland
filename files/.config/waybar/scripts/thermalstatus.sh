#!/usr/bin/env bash
set -u

cpu_json="$($HOME/.config/waybar/scripts/cputemp.sh 2>/dev/null || echo '{"text":"CPU n/a","class":"na"}')"
gpu_json="$($HOME/.config/waybar/scripts/gputemp.sh 2>/dev/null || echo '{"text":"GPU n/a","class":"na"}')"

extract_field() {
  local json="$1"
  local key="$2"
  printf '%s' "$json" | sed -n "s/.*\"${key}\":\"\([^\"]*\)\".*/\1/p"
}

extract_temp() {
  local text="$1"
  printf '%s' "$text" | grep -oE '[0-9]+' | head -n1
}

rank_class() {
  case "$1" in
    critical) echo 4 ;;
    hot) echo 3 ;;
    warm) echo 2 ;;
    cool) echo 1 ;;
    *) echo 0 ;;
  esac
}

cpu_class="$(extract_field "$cpu_json" "class")"
gpu_class="$(extract_field "$gpu_json" "class")"
cpu_temp="$(extract_temp "$(extract_field "$cpu_json" "text")")"
gpu_temp="$(extract_temp "$(extract_field "$gpu_json" "text")")"

cpu_rank="$(rank_class "$cpu_class")"
gpu_rank="$(rank_class "$gpu_class")"

status_class="$cpu_class"
if (( gpu_rank > cpu_rank )); then
  status_class="$gpu_class"
fi

status_text="THERM"
case "$status_class" in
  critical)
    status_text="THERM CRIT"
    ;;
  hot)
    status_text="THERM HOT"
    ;;
  warm)
    status_text="THERM WARM"
    ;;
  cool)
    status_text="THERM OK"
    ;;
  *)
    status_class="na"
    status_text="THERM N/A"
    ;;
esac

extra="CPU:${cpu_temp:-?}C GPU:${gpu_temp:-?}C"
printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$status_text" "$status_class" "$extra"
