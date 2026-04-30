#!/usr/bin/env bash
# Affiche ON si un des LEDs *::numlock est à 1

# Cherche la première LED numlock dispo
LED_PATH=$(ls /sys/class/leds/*::numlock/brightness 2>/dev/null | head -n1)

if [ -z "$LED_PATH" ]; then
  echo "❓ N/A"
  exit 0
fi

VAL=$(cat "$LED_PATH" 2>/dev/null)

if [ "$VAL" = "1" ]; then
  echo "🔢 ON"
else
  echo "❌ OFF"
fi
