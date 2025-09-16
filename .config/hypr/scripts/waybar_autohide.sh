#!/bin/bash

# Define the top threshold in pixels for showing Waybar
# Adjust this value based on your screen resolution and bar height.
# For example, if your bar is 30px high, you might want to show it when the mouse is in the top 5-10px.
TOP_THRESHOLD=5

# Function to hide Waybar
hide_waybar() {
    pkill -SIGUSR1 waybar
    echo "Waybar hidden"
}

# Function to show Waybar
show_waybar() {
    pkill -SIGUSR2 waybar # SIGUSR2 reloads style, SIGUSR1 toggles hide. If it's already hidden, SIGUSR1 shows it.
    echo "Waybar shown"
}

# Initial state: hide Waybar on script start
hide_waybar