#!/usr/bin/env bash
# Waybar status for power-profiles-daemon (JSON).

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    jq -cn '{text:"󰾆", class:"unknown", tooltip:"power-profiles-daemon not installed"}'; exit 0
fi

PROFILE=$(powerprofilesctl get 2>/dev/null)

case "$PROFILE" in
    performance) ICON="󰓅"; TEXT="Performance"; SHORT="Perf"; CLASS="performance" ;;
    balanced)    ICON="󰗑"; TEXT="Balanced";    SHORT="Bal";  CLASS="balanced" ;;
    power-saver) ICON="󰌪"; TEXT="Power Saver"; SHORT="Eco";  CLASS="power-saver" ;;
    *)           ICON="󰾆"; TEXT="Unknown";     SHORT="?";    CLASS="unknown" ;;
esac

TIP="Power profile: $TEXT"$'\n\n'"Click: next  •  Right-click: previous  •  Scroll: switch"

jq -cn --arg text "$ICON $SHORT" --arg class "$CLASS" --arg tip "$TIP" \
    '{text:$text, class:$class, tooltip:$tip}'
