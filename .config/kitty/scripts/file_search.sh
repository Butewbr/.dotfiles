#!/usr/bin/env bash
# --- Kitty Live Search Bar (fixed, with working scrolling) ---

TMP_FILE=/tmp/kitty_buffer.txt
kitty @ get-text > "$TMP_FILE"

matches=()
current_index=0
total_lines=$(wc -l < "$TMP_FILE")

search_and_highlight() {
    local query="$1"
    matches=()
    if [[ -z "$query" ]]; then
        return
    fi
    while IFS= read -r line; do
        matches+=("$line")
    done < <(grep -n -i --color=never "$query" "$TMP_FILE" || true)

    if (( ${#matches[@]} > 0 )); then
        current_index=0
        goto_match 0
    fi
}

goto_match() {
    local index="$1"
    if (( index < 0 )); then index=$((${#matches[@]} - 1)); fi
    if (( index >= ${#matches[@]} )); then index=0; fi
    current_index=$index

    local line_number=$(echo "${matches[$current_index]}" | cut -d: -f1)
    # Approximate scroll position (relative to total)
    local percent=$((100 * line_number / total_lines))
    kitty @ scroll-window home
    kitty @ scroll-window down $percent%
}

fzf --ansi \
    --bind "change:execute-silent(echo {q} > /tmp/kitty_query)" \
    --bind "enter:execute-silent(echo next > /tmp/kitty_action)+reload(echo)" \
    --prompt="🔍 Search: " \
    --height=10% --reverse --no-sort --no-multi < <(cat "$TMP_FILE") &

fzf_pid=$!

QUERY=""
while kill -0 $fzf_pid 2>/dev/null; do
    if [[ -f /tmp/kitty_query ]]; then
        new_query=$(cat /tmp/kitty_query)
        if [[ "$new_query" != "$QUERY" ]]; then
            QUERY="$new_query"
            search_and_highlight "$QUERY"
        fi
        rm -f /tmp/kitty_query
    fi

    if [[ -f /tmp/kitty_action ]]; then
        action=$(cat /tmp/kitty_action)
        if [[ "$action" == "next" ]]; then
            goto_match $((current_index + 1))
        elif [[ "$action" == "prev" ]]; then
            goto_match $((current_index - 1))
        fi
        rm -f /tmp/kitty_action
    fi
    sleep 0.05
done

rm -f /tmp/kitty_query /tmp/kitty_action
