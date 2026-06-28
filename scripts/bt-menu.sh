#!/bin/bash
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

# Get paired devices
DEVICES=$(bluetoothctl devices | awk '{print $2, $3}')

# Build menu
OPTIONS="Toggle Bluetooth\n"
while IFS= read -r line; do
    MAC=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $2}')
    STATUS=$(bluetoothctl info "$MAC" | grep "Connected" | awk '{print $2}')
    if [ "$STATUS" = "yes" ]; then
        OPTIONS+="Disconnect: $NAME\n"
    else
        OPTIONS+="Connect: $NAME\n"
    fi
done <<< "$DEVICES"

OPTIONS+="Open Manager"

CHOSEN=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Bluetooth")

case "$CHOSEN" in
    "Toggle Bluetooth")
        STATE=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
        if [ "$STATE" = "yes" ]; then
            bluetoothctl power off
            notify-send "Bluetooth" "Powered off"
        else
            bluetoothctl power on
            notify-send "Bluetooth" "Powered on"
        fi
        ;;
    Connect:*)
        NAME="${CHOSEN#Connect: }"
        MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
        bluetoothctl connect "$MAC"
        ;;
    Disconnect:*)
        NAME="${CHOSEN#Disconnect: }"
        MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
        bluetoothctl disconnect "$MAC"
        ;;
    "Open Manager")
        blueman-manager
        ;;
esac
