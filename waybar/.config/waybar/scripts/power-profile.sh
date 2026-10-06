#!/usr/bin/env bash
# Cycle power profiles.   power-profile.sh [next|prev]
# Only cycles through profiles your hardware actually offers.

command -v powerprofilesctl >/dev/null 2>&1 || {
    notify-send -u critical "Power profile" "power-profiles-daemon is not installed"; exit 1; }

dir="${1:-next}"
current=$(powerprofilesctl get 2>/dev/null) || exit 1
available=$(powerprofilesctl list | sed -nE 's/^[* ] ([a-z-]+):$/\1/p')

order=()
for p in performance balanced power-saver; do
    grep -qx "$p" <<< "$available" && order+=("$p")
done
[ "${#order[@]}" -eq 0 ] && exit 1

idx=0
for i in "${!order[@]}"; do
    [ "${order[$i]}" = "$current" ] && idx=$i
done

len=${#order[@]}
if [ "$dir" = "prev" ]; then
    new="${order[$(( (idx - 1 + len) % len ))]}"
else
    new="${order[$(( (idx + 1) % len ))]}"
fi

powerprofilesctl set "$new" || exit 1

case "$new" in
    performance) label="Performance" ;;
    balanced)    label="Balanced" ;;
    power-saver) label="Power Saver" ;;
esac

notify-send -u low -t 1500 -h string:x-dunst-stack-tag:power-profile "Power profile" "$label"
pkill -RTMIN+8 waybar 2>/dev/null
exit 0
