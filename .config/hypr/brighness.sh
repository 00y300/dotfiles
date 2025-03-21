#!/usr/bin/env sh

# Accept an arg '+' or '-'
direction=$1

# Get monitor info
monitor_data=$(hyprctl monitors -j)
focused_name=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .name')

if [ "$focused_name" == "eDP-1" ]; then
    # Internal display is focused -> use brillo
    if [ "$direction" == "-" ]; then
        brillo -u 150000 -U 3
    else
        brillo -u 150000 -A 3
    fi
else
    # External display is focused -> use ddcutil
    # But *which* external display?
    focused_id=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .id')
    ddcutil --display=$focused_id setvcp 10 $direction 8
fi
