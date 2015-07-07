#!/bin/sh
#xrandr --output eDP1    --mode 1920x1080 --pos 0x8000
#xrandr 	--output DP1-1   --mode 1920x1080 --rate 59.9 --pos 0x0 --rotate left \

#xrandr --output DP1-2-2 --mode 1920x1080_DELLU2414H  --pos 3000x0   --rotate right

# turn on monitor and turn off laptop display
xrandr --output DP1-2-1 --mode 1920x1080 --rate 59.9 --pos 1080x310 --rotate normal --primary --output eDP1 --off --output DP1-1 --off --output DP1-2-2 --off