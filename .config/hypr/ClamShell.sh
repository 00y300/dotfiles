#!/usr/bin/env zsh

# Check if 'hyprctl monitors' output contains at least one DP-* or HDMI-* monitor
if hyprctl monitors | grep -E 'Monitor (DP|HDMI)' >/dev/null; then
  if [[ $1 == "open" ]]; then
    hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1.25"
  else
    hyprctl keyword monitor "eDP-1,disable"
  fi
fi
