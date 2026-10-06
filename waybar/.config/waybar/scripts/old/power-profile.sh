#!/bin/bash

PROFILE=$(powerprofilesctl get)

case "$PROFILE" in

    performance)
        powerprofilesctl set balanced
        ;;

    balanced)
        powerprofilesctl set power-saver
        ;;

    power-saver)
        powerprofilesctl set performance
        ;;

esac
