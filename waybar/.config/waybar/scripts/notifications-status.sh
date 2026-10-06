#!/usr/bin/env bash
# Waybar status for dunst: icon + class (idle / pending / dnd) + tooltip.

command -v dunstctl >/dev/null 2>&1 || {
  jq -cn '{text:"󰂚", class:"idle", tooltip:"dunst not installed"}'
  exit 0
}

paused=$(dunstctl is-paused 2>/dev/null)
shown=$(dunstctl count displayed 2>/dev/null || echo 0)
waiting=$(dunstctl count waiting 2>/dev/null || echo 0)
history=$(dunstctl count history 2>/dev/null || echo 0)

if [ "$paused" = "true" ]; then
  icon=$'\U000F009B'
  class="dnd"
  state="Do Not Disturb: on"
elif [ "$shown" -gt 0 ] || [ "$waiting" -gt 0 ]; then
  icon=$'\U000F009E'
  class="pending"
  state="Do Not Disturb: off"
else
  icon=$'\U000F009A'
  class="idle"
  state="Do Not Disturb: off"
fi

tip="$state"$'\n'"Active: $shown   Queued: $waiting   History: $history"
tip+=$'\n\n'"Click: history  •  Right-click: toggle DND  •  Middle-click: clear history"

jq -cn --arg text "$icon" --arg class "$class" --arg tip "$tip" \
  '{text:$text, class:$class, tooltip:$tip}'
