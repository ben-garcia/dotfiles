#!/usr/bin/env bash
#
# This script changes the power-profiles.

# No point of running script if not running on a laptop.
if [ ! -d /sys/class/power_supply/BAT0 ]; then
  notify-send "Power Profiles" "Desktop detected, nothing to do" -u low
  exit 0
fi

# Use wofi on Wayland and rofi on X11
if [ "$WAYLAND_DISPLAY" == "wayland" ]; then
  dmenu_command=wofi
else
  dmenu_command=rofi
fi

# Create array of all power profiles options:
#   1. `powerprofilesctl` -- to list the available options
#   2. `grep` -- options ends with ':'
#   3. `sed` -- remove leading spaces and the ':' at the end
options=($(powerprofilesctl list | grep ':$' | sed -e 's/^[ *]*//' -e 's/:$//'))

# Get the current power profile
current_option=$(powerprofilesctl get)

# Get the choice
#  1. `printf` - concatinate options array
#  2. `rofi/wofi` - render menu with all power profiles options
choice=$(printf "%s\n" "${options[@]}"  | "$dmenu_command" -dmenu -i -no-custom -p "Power Profiles ($current_option)")

# powerprofilesctl set "$choice"

# Trigger notification 
notify-send "Power Profile" "Succesfully switched to $choice"
