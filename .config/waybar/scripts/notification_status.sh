#!/bin/bash

# Function to emit correct icon state
print_status() {
    if swaync-client -d | grep -q '"dnd": true'; then
        echo '{"text": "󰂛"}'
        return
    fi

    if swaync-client -swc | grep -q '"urgency":'; then
        echo '{"text": "󱅫"}'
    else
        echo '{"text": "󰂚"}'
    fi
}

# Initial state
print_status

# Listen for changes: notifications or config changes (like DND)
swaync-client --on-notify | while read -r _; do
    print_status
done &

swaync-client --on-config-update | while read -r _; do
    print_status
done
