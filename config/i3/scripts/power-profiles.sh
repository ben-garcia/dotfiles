#!/usr/bin/env bash
#
# This script changes the power-profiles.

# No point of running script if not running on a laptop.
if [ ! -d /sys/class/power_supply/BAT0 ]; then
  notify-send "Power Profiles" "Desktop detected, nothing to do" -u low
  exit 0
fi

# Check if powerprofilesctl is installed
if ! command -v powerprofilesctl &> /dev/null; then
  notify-send "Power Profiles" "powerprofilesctl not found" -u critical
  exit 1
fi

# Use wofi on Wayland and rofi on X11
if [ -n "$WAYLAND_DISPLAY" ]; then
  dmenu_command=wofi
else
  dmenu_command=rofi
fi

# Create array of all power profiles options:
#   1. `powerprofilesctl` -- to list the available options
#   2. `grep` -- options ends with ':'
#   3. `sed` -- remove leading spaces and the ':' at the end
options=($(powerprofilesctl list | grep ':$' | sed -e 's/^[ *]*//' -e 's/:$//'))

# Exit if no options found
if [ ${#options[@]} -eq 0 ]; then
  notify-send "Power Profiles" "No profiles found" -u critical
  exit 1
fi

# Get the current power profile
current_option=$(powerprofilesctl get)

# Get the choice
#  1. `printf` - concatenate options array
#  2. `rofi/wofi` - render menu with all power profiles options
choice=$(printf "%s\n" "${options[@]}" | "$dmenu_command" -dmenu -i -no-custom -p "Power Profiles ($current_option)")

# Exit if user cancelled
if [ -z "$choice" ]; then
  exit 0
fi

# Actually change the power profile
if powerprofilesctl set "$choice"; then
  notify-send "Power Profile" "Successfully switched to $choice" -u low
else
  notify-send "Power Profile" "Failed to switch to $choice" -u critical
fi

