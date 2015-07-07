#!/bin/sh
# add mode if it has been forgotten
xrandr --addmode DP1-2-2 1920x1080_DELLU2414H

# turn on and position all monitors, for some reason can't all at the same time
xrandr --output DP1-1 --mode 1920x1080 --rate 59.9 --pos 0x0 --rotate left
xrandr --output DP1-2-1 --mode 1920x1080 --rate 59.9 --pos 1080x315 --rotate normal
xrandr --output DP1-2-2 --mode 1920x1080_DELLU2414H --pos 3000x0 --rotate right