#!/bin/sh
# first, turn off two monitors to make way for booting laptop display
xrandr --output DP1-1 --off \
--output DP1-2-2 --off
# turn on laptop display and turn off last monitor
xrandr --output eDP1 --mode 1920x1080 --rate 59.9 --pos 1080x0 --output DP1-2-1 --off
       

