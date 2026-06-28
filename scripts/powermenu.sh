#!/bin/bash
OPTIONS="Logout\nReboot\nShutdown\nSuspend\nLock"
CHOSEN=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Power")
case $CHOSEN in
  Logout)   hyprctl dispatch exit ;;
  Reboot)   systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  Suspend)  systemctl suspend ;;
  Lock)     hyprlock ;;
esac
