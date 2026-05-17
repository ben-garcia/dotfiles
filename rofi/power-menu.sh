#!/bin/bash

options="Poweroff\nReboot\nLogout\nSuspend\nHibernate"
choice=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

case $choice in
    Poweroff)       systemctl poweroff ;;
    Reboot)         systemctl reboot ;;
    Logout)         i3-msg exit ;;  # or use `exit` for other desktops
    Suspend)        systemctl suspend ;;
    Hibernate)      systemctl hibernate ;;
esac
