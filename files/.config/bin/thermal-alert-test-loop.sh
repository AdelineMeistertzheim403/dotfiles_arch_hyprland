#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-both}"
TEMP="${2:-95}"
COUNT="${3:-3}"
DELAY="${4:-3}"

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || ! [[ "$DELAY" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 [cpu|gpu|both] [temp] [count] [delay_seconds]"
  exit 1
fi

for i in $(seq 1 "$COUNT"); do
  "$HOME/.config/bin/thermal-alert-test.sh" "$TARGET" "$TEMP"
  if (( i < COUNT )); then
    sleep "$DELAY"
  fi
done

echo "Loop test complete: target=$TARGET temp=${TEMP}C count=$COUNT delay=${DELAY}s"
