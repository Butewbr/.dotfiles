#!/bin/bash

# Usage: launch_or_focus.sh <window_class> <command_to_launch> [optional_additional_command_args]

window_class="$1"
shift 
command_to_launch="$@" 

if [ -z "$window_class" ] || [ -z "$command_to_launch" ]; then
    echo "Usage: $0 <window_class> <command_to_launch> [optional_additional_command_args]"
    exit 1
fi

# Define the title to ignore (Picture in Picture)
ignore_title="화면 속 화면"

# Updated jq filter: 
# 1. Matches the class
# 2. AND ensures the title is NOT the ignore_title
window_id=$(hyprctl clients -j | jq -r --arg CLASS "$window_class" --arg IGNORE "$ignore_title" \
    '.[] | select(.class == $CLASS and .title != $IGNORE) | .address' | head -n 1)

if [ -n "$window_id" ]; then
    hyprctl dispatch focuswindow address:"$window_id"
    echo "mousemove 1 1" | dotoolc
    echo "mousemove -1 -1" | dotoolc
else
    eval "$command_to_launch" & 
fi