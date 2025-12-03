#!/bin/bash
LOGFILE="/tmp/emoji_picker.log"

> "$LOGFILE"

{
    echo "=== Script started at $(date) ==="
    
    echo -e "\n=== Checking dotool daemon ==="
    ps aux | grep dotool | grep -v grep
    
    echo -e "\n=== Running ulauncher-toggle ==="
    ulauncher-toggle -q "em " 2>&1
    echo "ulauncher exit code: $?"
    
    sleep 0.1
    
    echo -e "\n=== Sending key right ==="
    echo 'key right' | /usr/bin/dotoolc 2>&1
    echo "dotoolc exit code: $?"
    
    echo -e "\n=== Script finished ==="
} >> "$LOGFILE" 2>&1