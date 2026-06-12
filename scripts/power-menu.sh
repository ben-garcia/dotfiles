#!/usr/bin/env bash
#
# This script uses rofi/wofi to render a Power Menu

if [ -n "$WAYLAND_DISPLAY" ]; then
    # Make wofi act like rofi fuzzy matching and case insensitivity
    dmenu_command="wofi --dmenu --matching fuzzy --insensitive"
    logout_command=swaymsg
else
    # Rofi handles this natively with -dmenu -i
    dmenu_command="rofi -dmenu -i -no-custom"
    logout_command=i3-msg
fi

options="Poweroff\nReboot\nLogout\nSuspend\nHibernate"
choice=$(echo -e "$options" | $dmenu_command -p "Power Menu")

case $choice in
    Poweroff)       systemctl poweroff ;;
    Reboot)         systemctl reboot ;;
    Logout)         "$logout_command" exit ;;
    Suspend)        systemctl suspend ;;
    Hibernate)      systemctl hibernate ;;
esac
