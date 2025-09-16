#!/bin/bash

# Function to get active VPN connection
get_active_vpn() {
    nmcli -t -f TYPE,STATE,NAME connection show --active | grep "^vpn" | cut -d':' -f3
}

# Function to list all VPN connections
list_vpn_connections() {
    nmcli -t -f NAME,TYPE connection show | grep "vpn" | cut -d':' -f1
}

# Function to connect to a VPN
connect_vpn() {
    nmcli connection up "$1"
}

# Function to disconnect a VPN
disconnect_vpn() {
    nmcli connection down "$1"
}

# Main logic
case "$1" in
    "status")
        ACTIVE_VPN=$(get_active_vpn)
        if [ -n "$ACTIVE_VPN" ]; then
            echo '{"text": "", "tooltip": "'"$ACTIVE_VPN"'", "class": "active"}'
        else
            echo '{"text": "", "tooltip": "VPN 연결되지 않음", "class": "inactive"}'
        fi
        ;;
    "toggle")
        VPN_NAME="$2"
        ACTIVE_VPN=$(get_active_vpn)

        if [ -n "$ACTIVE_VPN" ] && [ "$ACTIVE_VPN" == "$VPN_NAME" ]; then
            # If the clicked VPN is active, disconnect it
            disconnect_vpn "$VPN_NAME" > /dev/null 2>&1
        elif [ -n "$ACTIVE_VPN" ]; then
            # If another VPN is active, disconnect it first, then connect to the new one
            disconnect_vpn "$ACTIVE_VPN" > /dev/null 2>&1
            connect_vpn "$VPN_NAME" > /dev/null 2>&1
        else
            # No VPN active, connect to the clicked one
            connect_vpn "$VPN_NAME" > /dev/null 2>&1
        fi
        ;;
    "list")
        echo "{\"items\": ["
        FIRST=true
        while IFS= read -r vpn; do
            if [ "$FIRST" = false ]; then
                echo ","
            fi
            echo -n "{\"name\": \"$vpn\"}"
            FIRST=false
        done < <(list_vpn_connections)
        echo "]}"
        ;;
    *)
        echo "Usage: $0 {status|toggle <VPN_NAME>|list}"
        exit 1
        ;;
esac