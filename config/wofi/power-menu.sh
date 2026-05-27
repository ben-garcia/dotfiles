#!/bin/bash

options="Poweroff\nReboot\nLogout\nSuspend\nHibernate"

# Use wofi in dmenu mode, hiding the search bar since it's a static list
choice=$(echo -e "$options" | wofi --dmenu --hide-scroll --search-disabled --prompt "Power Menu")

case $choice in
    Poweroff)   systemctl poweroff ;;
    Reboot)     systemctl reboot ;;
    Logout)     swaymsg exit ;;  # Updated for Sway/Wayland
    Suspend)    systemctl suspend ;;
    Hibernate)  systemctl hibernate ;;
esac
