#!/bin/sh
# Start JankyBorders and stop it when AeroSpace quits, so no window
# borders stay on screen without the tiling manager.
# AeroSpace runs this script from after-startup-command.

pkill -x borders
/opt/homebrew/bin/borders active_color=0xfffabd2f inactive_color=0xff3c3836 \
  width=5.0 style=round hidpi=on &

while pgrep -x AeroSpace >/dev/null; do
  sleep 2
done
pkill -x borders
