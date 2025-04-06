#!/usr/bin/env sh

# Accepts '+' or '-' as argument
direction=$1

# Get monitor info from Hyprland
monitor_data=$(hyprctl monitors -j)
focused_monitor=$(echo "$monitor_data" | jq -r '.[] | select(.focused == true) | .name')

# Internal display
if [ "$focused_monitor" = "eDP-1" ]; then
    if [ "$direction" = "-" ]; then
        brillo -u 150000 -U 3
    else
        brillo -u 150000 -A 3
    fi
else
    # External monitor – map Hyprland names to ddcutil display numbers (or use --bus=)
    case "$focused_monitor" in
        "DP-1")
            ddc_display=1  # Change this according to your `ddcutil detect` output
            ;;
        "DP-2")
            ddc_display=2  # Change this according to your `ddcutil detect` output
            ;;
        *)
            exit 1
            ;;
    esac

    if [ "$direction" = "-" ]; then
        ddcutil --display=$ddc_display setvcp 10 - 5
    else
        ddcutil --display=$ddc_display setvcp 10 + 5
    fi
fi
