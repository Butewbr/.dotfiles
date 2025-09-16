#!/bin/bash

# This script either focuses an existing window of a given class/title
# or launches a new instance of the application.

# Usage: launch_or_focus.sh <window_class> <command_to_launch> [optional_additional_command_args]

# Example:
# launch_or_focus.sh kitty kitty
# launch_or_focus.sh code code
# launch_or_focus.sh Brave brave --incognito

window_class="$1"
shift # Remove the first argument (window_class)

command_to_launch="$@" # All remaining arguments form the command

if [ -z "$window_class" ] || [ -z "$command_to_launch" ]; then
    echo "Usage: $0 <window_class> <command_to_launch> [optional_additional_command_args]"
    exit 1
fi

# Use hyprctl to find windows matching the class
# hyprctl clients -j returns a JSON array of all active windows.
# We then use jq to filter by the 'class' field and get the 'address' (window ID).
# 'grep -m 1' is used to get only the first match, as we only need one to focus.
window_id=$(hyprctl clients -j | jq -r --arg CLASS "$window_class" '.[] | select(.class == $CLASS) | .address' | head -n 1)

if [ -n "$window_id" ]; then
    # Window found, focus it
    hyprctl dispatch focuswindow address:"$window_id"
else
    # No window found, launch the application
    eval "$command_to_launch" & # '&' to run in background so script doesn't wait
fi