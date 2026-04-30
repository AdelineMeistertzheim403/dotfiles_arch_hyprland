#!/usr/bin/env bash
LED_PATH=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -n1)

if [ -z "$LED_PATH" ]; then
  echo "⇪ N/A"
  exit 0
fi

VAL=$(cat "$LED_PATH" 2>/dev/null)

if [ "$VAL" = "1" ]; then
  echo "⇪ ON"
else
  echo "⇪ off"
fi
