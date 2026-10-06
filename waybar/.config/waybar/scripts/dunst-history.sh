#!/usr/bin/env bash
# Readable notification history for dunst, shown in rofi.
#   Enter  → show the notification again
#   Alt+c  → copy its text to the clipboard
#   Alt+d  → delete it from history
# Needs: dunst, jq, rofi (rofi-wayland on Hyprland). Optional: wl-clipboard.

DIR="$(dirname "$(readlink -f "$0")")"
THEME="$DIR/notifications.rasi"

for cmd in dunstctl jq rofi; do
    command -v "$cmd" >/dev/null 2>&1 || {
        notify-send -u critical "Notification history" "Missing dependency: $cmd"
        exit 1
    }
done

read -r -d '' JQ_PROG << 'JQ'
def plain:   (. // "") | gsub("</?(b|i|u|a|img|s|span|big|small|tt)( [^>]*)?>";"";"i") | gsub("&lt;";"<") | gsub("&gt;";">")
             | gsub("&quot;";"\"") | gsub("&amp;";"&")
             | gsub("[\\n\\r\\t]+";" ") | gsub("\\s+";" ") | gsub("^ | $";"");
def trunc($n): if length > $n then .[0:$n] + "…" else . end;
def esc:     gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
def ago($s): if   $s < 60    then "just now"
             elif $s < 3600  then "\($s/60   | floor)m ago"
             elif $s < 86400 then "\($s/3600 | floor)h ago"
             else                 "\($s/86400| floor)d ago" end;
def color:   if . == "CRITICAL" then "#fb4934" elif . == "LOW" then "#928374" else "#fabd2f" end;

.data[0] | sort_by(-.timestamp.data) | .[] |
  (.summary.data | plain) as $sum |
  (.body.data    | plain) as $body |
  (.appname.data | plain) as $app |
  ((($up * 1000000) - .timestamp.data) / 1000000 | floor) as $age |
  [
    (.id.data | tostring),
    "<span foreground='\(.urgency.data | color)'><b>\($sum | trunc(60) | esc)</b></span>   <span foreground='#928374' size='small'>\($app | esc) · \(ago($age))</span>",
    (if $body == "" then "<span foreground='#665c54'>(no message)</span>"
     else "<span foreground='#a89984'>\($body | trunc(110) | esc)</span>" end),
    ("\($sum)\(if $body == "" then "" else " — " + $body end)")
  ] | join("\t")
JQ

while true; do
    uptime=$(cut -d' ' -f1 /proc/uptime)
    parsed=$(dunstctl history | jq -r --argjson up "$uptime" "$JQ_PROG" 2>/dev/null)

    if [ -z "$parsed" ]; then
        notify-send -u low -t 2000 "Notifications" "No notification history"
        exit 0
    fi

    ids=(); texts=(); rows=()
    paused=$(dunstctl is-paused 2>/dev/null)
    if [ "$paused" = "true" ]; then dnd_label="Turn Do Not Disturb off"; else dnd_label="Turn Do Not Disturb on"; fi

    rows+=("<b>󰎟  Clear all history</b>"$'\n'"<span foreground='#928374'>Remove every stored notification</span>")
    rows+=("<b>󰂛  $dnd_label</b>"$'\n'"<span foreground='#928374'>Pause or resume popups</span>")

    while IFS=$'\t' read -r id l1 l2 txt; do
        ids+=("$id"); texts+=("$txt")
        rows+=("$l1"$'\n'"$l2")
    done <<< "$parsed"

    choice=$(printf '%s\0' "${rows[@]}" | rofi -dmenu -i -no-custom \
        -sep '\0' -eh 2 -markup-rows -format i \
        -p "󰂚" \
        -mesg "Enter: show again   ·   Alt+c: copy   ·   Alt+d: delete" \
        -kb-custom-1 "Alt+c" -kb-custom-2 "Alt+d" \
        -theme "$THEME")
    code=$?

    [ -z "$choice" ] && exit 0

    case "$choice" in
        0)  dunstctl history-clear
            notify-send -u low -t 1500 "Notifications" "History cleared"
            pkill -RTMIN+9 waybar 2>/dev/null
            exit 0 ;;
        1)  dunstctl set-paused toggle
            pkill -RTMIN+9 waybar 2>/dev/null
            exit 0 ;;
    esac

    n=$((choice - 2))
    case "$code" in
        0)  dunstctl history-pop "${ids[$n]}"; exit 0 ;;
        10) if command -v wl-copy >/dev/null 2>&1; then
                printf '%s' "${texts[$n]}" | wl-copy
            elif command -v xclip >/dev/null 2>&1; then
                printf '%s' "${texts[$n]}" | xclip -selection clipboard
            else
                notify-send -u low "Notifications" "Install wl-clipboard to copy"
                exit 0
            fi
            notify-send -u low -t 1500 "Notifications" "Copied to clipboard"
            exit 0 ;;
        11) dunstctl history-rm "${ids[$n]}" ;;   # loop → list refreshes
        *)  exit 0 ;;
    esac
done
