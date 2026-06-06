#!/usr/bin/env bash
#
# This script uses rofi/wofi to render a Power Menu

if [ -n "$WAYLAND_DISPLAY" ]; then
  dmenu_command=wofi
  logout_command=swaymsg
else
  dmenu_command=rofi
  logout_command=i3-msg
fi

options="Poweroff\nReboot\nLogout\nSuspend\nHibernate"
choice=$(echo -e "$options" | "$dmenu_command" -dmenu -i -no-custom -p "Power Menu")

case $choice in
    Poweroff)       systemctl poweroff ;;
    Reboot)         systemctl reboot ;;
    Logout)         "$logout_command" exit ;;  # or use `exit` for other desktops
    Suspend)        systemctl suspend ;;
    Hibernate)      systemctl hibernate ;;
esac
