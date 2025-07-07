#!/bin/sh
$(dirname $0)/monitor.sh # workaround for i3bar to show correct workspace numbers
# xrandr --output eDP-1 --off --output DP-2 --off --output DP-3 --off --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1-0 --off --output DP-1-1 --primary --mode 1920x1080 --pos 0x1080 --rotate normal
xrandr --output HDMI-0 --off --output DP-0 --off --output DP-1 --primary --mode 1920x1080 --pos 0x1080 --rotate normal --output eDP-1-1 --off --output DP-1-2 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1-3 --off
