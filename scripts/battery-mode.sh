#!/bin/bash
CONSERVATION=/sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode
current=$(cat $CONSERVATION)
if [ "$current" = "1" ]; then
    echo 0 | sudo tee $CONSERVATION
    notify-send "Battery" "Conservation mode OFF — charging to 100%"
else
    echo 1 | sudo tee $CONSERVATION
    notify-send "Battery" "Conservation mode ON — charging limited to 80%"
fi
