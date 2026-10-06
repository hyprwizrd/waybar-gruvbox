#!/bin/bash

HISTORY=$(dunstctl history)

if [ -z "$HISTORY" ]; then
    notify-send "Notifications" "No notification history"
    exit 0
fi

CHOICE=$(printf '%s\n' "$HISTORY" | \
    rofi -dmenu \
    -i \
    -p "Notifications" \
    -theme-str '
        window {
            width: 650px;
            border: 2px;
            border-color: #504945;
            border-radius: 10px;
            background-color: #282828;
        }

        mainbox {
            background-color: #282828;
            children: [inputbar, listview];
        }

        inputbar {
            padding: 12px;
            background-color: #3c3836;
            children: [prompt, entry];
        }

        prompt {
            text-color: #d79921;
            padding: 0 10px 0 0;
        }

        entry {
            text-color: #ebdbb2;
            placeholder: "Search notifications...";
            placeholder-color: #a89984;
        }

        listview {
            padding: 8px;
            lines: 12;
            columns: 1;
            scrollbar: false;
        }

        element {
            padding: 10px;
            background-color: #282828;
            text-color: #ebdbb2;
        }

        element selected {
            background-color: #504945;
            text-color: #fabd2f;
        }

        element-text {
            background-color: transparent;
            text-color: inherit;
        }
    ')

if [ -n "$CHOICE" ]; then
    notify-send "Notification" "$CHOICE"
fi
