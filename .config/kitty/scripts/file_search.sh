#!/usr/bin/env bash
# Kitty Live Search - searches current terminal buffer

TMP_FILE="/tmp/kitty_search_$$"
QUERY_FILE="/tmp/kitty_query_$$"
INDEX_FILE="/tmp/kitty_index_$$"

# Cleanup on exit
cleanup() {
    rm -f "$TMP_FILE" "$QUERY_FILE" "$INDEX_FILE"
    kitty @ set-colors --reset
}
trap cleanup EXIT

# Get current terminal content
kitty @ get-text > "$TMP_FILE"

# Initialize
echo "" > "$QUERY_FILE"
echo "0" > "$INDEX_FILE"

# Function to find all matches
find_matches() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "0"
        return
    fi
    grep -i -n "$query" "$TMP_FILE" | wc -l
}

# Function to go to nth match
goto_match() {
    local query="$1"
    local index="$2"
    
    if [[ -z "$query" ]]; then
        return
    fi
    
    # Get all line numbers with matches
    local line_nums=($(grep -i -n "$query" "$TMP_FILE" | cut -d: -f1))
    local total="${#line_nums[@]}"
    
    if (( total == 0 )); then
        return
    fi
    
    # Wrap around
    if (( index < 0 )); then
        index=$((total - 1))
    elif (( index >= total )); then
        index=0
    fi
    
    echo "$index" > "$INDEX_FILE"
    
    # Scroll to the line
    local target_line="${line_nums[$index]}"
    local total_lines=$(wc -l < "$TMP_FILE")
    
    # Scroll to top first, then to target
    kitty @ scroll-window home
    if (( target_line > 10 )); then
        kitty @ scroll-window down $((target_line - 10))
    fi
}

# Launch overlay search using kitty's overlay feature
kitty @ launch --type=overlay --hold \
    bash -c '
    QUERY_FILE="'"$QUERY_FILE"'"
    INDEX_FILE="'"$INDEX_FILE"'"
    TMP_FILE="'"$TMP_FILE"'"
    
    QUERY=""
    INDEX=0
    
    echo -e "\033[2J\033[H"  # Clear screen
    echo "🔍 Search (Enter: next, Shift+Enter: prev, Esc: exit)"
    echo -n "> "
    
    # Read input character by character
    while IFS= read -rsn1 char; do
        case "$char" in
            $'\''\x1b'\'')  # Escape key
                read -rsn2 -t 0.01 rest
                if [[ "$rest" == "[A" ]]; then  # Up arrow (Shift+Enter in some terminals)
                    INDEX=$((INDEX - 1))
                    echo "$INDEX" > "$INDEX_FILE"
                    kill -USR1 '"$$"'
                elif [[ -z "$rest" ]]; then  # Pure escape
                    exit 0
                fi
                ;;
            "")  # Enter key
                INDEX=$((INDEX + 1))
                echo "$INDEX" > "$INDEX_FILE"
                kill -USR1 '"$$"'
                ;;
            $'\''\x7f'\'')  # Backspace
                if (( ${#QUERY} > 0 )); then
                    QUERY="${QUERY%?}"
                    echo "$QUERY" > "$QUERY_FILE"
                    INDEX=0
                    echo "0" > "$INDEX_FILE"
                    kill -USR2 '"$$"'
                    echo -e "\033[2K\r> $QUERY\c"
                fi
                ;;
            *)
                if [[ -n "$char" ]]; then
                    QUERY="$QUERY$char"
                    echo "$QUERY" > "$QUERY_FILE"
                    INDEX=0
                    echo "0" > "$INDEX_FILE"
                    kill -USR2 '"$$"'
                    echo -n "$char"
                fi
                ;;
        esac
    done
'

# Handle signals from overlay
handle_search() {
    QUERY=$(cat "$QUERY_FILE")
    goto_match "$QUERY" 0
}

handle_navigate() {
    QUERY=$(cat "$QUERY_FILE")
    INDEX=$(cat "$INDEX_FILE")
    goto_match "$QUERY" "$INDEX"
}

trap handle_search USR2
trap handle_navigate USR1

# Keep script running
wait