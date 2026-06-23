#!/bin/bash
FILE=~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
case $1 in
  full)
    grim "$FILE" && wl-copy < "$FILE"
    ;;
  region)
    grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"
    ;;
  annotate)
    grim -g "$(slurp)" "$FILE" && swappy -f "$FILE"
    ;;
esac
