#!/usr/bin/env bash
#
# This script toggles the trackpad.

# stores both the name and id of the trackpad device
relevant_info=$(xinput list | sed -n -E 's/\W+(.*Touchpad).*id=([0-9]*).*/\2$\1/p')

if [ ${#relevant_info} -eq 0 ]; then
  # no touchpad device was found, which can indicate the machine is not a laptop.
  # program will terminate.
  # notify me about this before terminating 
  notify-send 'Trackpad Status' 'Failed to detect a touchpad device.' -u normal
  exit 1
fi

# device id
id=$(echo $relevant_info | cut -d$ -f1)
# device name
name=$(echo $relevant_info | cut -d$ -f2)
# status of trackpad
is_enabled=$(xinput list-props "$name" | grep -i "Device enabled" | cut -d ':' -f2)

if [ $is_enabled -eq 1 ]; then
  # indicates trackpad is enabled, so disable and notify me
  xinput disable $id;
  notify-send 'Trackpad Status' 'Disabled' -u normal
else
  # indicates trackpad is disabled, so enable and notify me
  xinput enable $id;
  notify-send 'Trackpad Status' 'Enabled' -u normal
fi
