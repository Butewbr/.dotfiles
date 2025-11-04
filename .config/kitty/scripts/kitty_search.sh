#!/usr/bin/env bash
# --- Kitty VSCode-style visual search ---

TMP_TEXT=/tmp/kitty_vscode_buffer.txt
TMP_COLOR=/tmp/kitty_vscode_colors.conf
kitty @ get-text > "$TMP_TEXT"

# define highlight colour (bright yellow background)
cat > "$TMP_COLOR" <<EOF
cursor none
selection_foreground none
selection_background #ffff00
EOF

matches=()
current_index=0
total_lines=$(wc -l < "$TMP_TEXT")

highlight_matches() {
    local query="$1"
    if [[ -z "$query" ]]; then
        kitty @ set-colors --all --reset
        return
    fi
    kitty @ set-colors --all --configured "$TMP_COLOR"

    # Colourize matches inline and show in fzf preview
    grep -in --color=always -- "$query" "$TMP_TEXT" 2>/dev/null
}

goto_match() {
    local index="$1"
    (( index < 0 )) && index=$((${#matches[@]} - 1))
    (( index >= ${#matches[@]} )) && index=0
    current_index=$index
    local line_number=$(echo "${matches[$current_index]}" | cut -d: -f1)
    local percent=$((100 * line_number / total_lines))
    kitty @ scroll-window --home
    kitty @ scroll-window down $percent%
}

fzf --ansi --no-sort --no-multi --reverse \
    --prompt="🔍 Search: " \
    --height=10% \
    --bind "change:reload(grep -in --color=always -- {q} $TMP_TEXT || true)" \
    --bind "enter:execute-silent(echo next > /tmp/kitty_action)" \
    --preview-window=up:wrap:5 < <(cat "$TMP_TEXT") &

fzf_pid=$!

QUERY=""
while kill -0 $fzf_pid 2>/dev/null; do
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

kitty @ set-colors --all --reset
rm -f "$TMP_TEXT" "$TMP_COLOR" /tmp/kitty_action
