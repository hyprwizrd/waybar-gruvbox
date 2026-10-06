#!/bin/bash

PROFILE=$(powerprofilesctl get)

case "$PROFILE" in

    performance)
        ICON="󰓅"
        TEXT="Performance"
        CLASS="performance"
        ;;

    balanced)
        ICON="󰗑"
        TEXT="Balanced"
        CLASS="balanced"
        ;;

    power-saver)
        ICON="󰌪"
        TEXT="Power Saver"
        CLASS="power-saver"
        ;;

    *)
        ICON="󰾆"
        TEXT="Unknown"
        CLASS="unknown"
        ;;

esac

printf '{"text":"%s","class":"%s","tooltip":"Power Profile: %s"}\n' \
    "$ICON" "$CLASS" "$TEXT"
