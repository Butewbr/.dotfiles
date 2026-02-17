#!/bin/bash

# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/.config/backgrounds"

# 1. Select wallpaper using Rofi
# We list files in the dir, pipe to rofi, and save selected file to variable
SELECTED=$(ls "$WALLPAPER_DIR" | wofi -dmenu -p "Select Theme/Wallpaper")

# Exit if no selection (user pressed Esc)
if [ -z "$SELECTED" ]; then
    exit 0
fi

FULL_PATH="$WALLPAPER_DIR/$SELECTED"

# 2. Ask for Light or Dark Mode
MODE=$(echo -e "Dark\nLight" | wofi -dmenu -p "Select Mode")

# 3. Generate Colors
# We use 'haishoku' backend for better contrast
# We add -l flag if user selected Light
if [ "$MODE" = "Light" ]; then
    wal -i "$FULL_PATH" -l -n -q
else
    wal -i "$FULL_PATH" -n -q
fi

# 4. Apply Wallpaper (Wait for generation to finish first)
swww img "$FULL_PATH" --transition-type grow --transition-pos 0.9,0.9 --transition-step 90

killall swaync
swaync &

# 5. Reload Apps
# Reload Waybar
killall -SIGUSR2 waybar

# Send escape sequences to all open terminals to update colors immediately
# (This fixes the background/foreground without needing a full reload)
wal -R

killall -SIGUSR1 kitty

# Reload Hyprland
hyprctl reload

# Update Pywalfox (Zen)
pywalfox update