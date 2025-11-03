#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Installing user dotfiles with stow..."
stow --verbose --target="$HOME" --restow --no-folding .

echo ">>> Installing SDDM configuration and theme..."

# --- Variables ---
SDDM_CONF_SRC="$DOTFILES_DIR/sddm/etc/sddm.conf"
SDDM_CONF_TARGET="/etc/sddm.conf"

SDDM_SCRIPT_SRC="$DOTFILES_DIR/sddm/usr/share/sddm/scripts"
SDDM_SCRIPT_TARGET="/usr/share/sddm/scripts"

SDDM_THEME_NAME="Sugar-Candy"
SDDM_THEME_SRC="$DOTFILES_DIR/sddm/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_THEME_TARGET="/usr/share/sddm/themes/$SDDM_THEME_NAME"

# --- Install sddm.conf ---
if [ -f "$SDDM_CONF_SRC" ]; then
    if [ "$(readlink -f "$SDDM_CONF_SRC")" = "$(readlink -f "$SDDM_CONF_TARGET")" ]; then
        echo "sddm.conf is already linked to the target, skipping copy."
    else
        echo "Copying sddm.conf to $SDDM_CONF_TARGET"
        sudo cp "$SDDM_CONF_SRC" "$SDDM_CONF_TARGET"
    fi
else
    echo "Warning: $SDDM_CONF_SRC not found!"
fi

# --- Install Xsetup ---
if [ -d "$SDDM_SCRIPT_SRC" ]; then
    echo "Copying scripts $SDDM_SCRIPT_TARGET"
    sudo cp -r "$SDDM_SCRIPT_SRC" "$SDDM_SCRIPT_TARGET"
else
    echo "Warning: $SDDM_SCRIPT_SRC not found!"
fi

# --- Install SDDM theme ---
if [ -d "$SDDM_THEME_TARGET" ]; then
    echo "Removing old SDDM theme at $SDDM_THEME_TARGET"
    sudo rm -rf "$SDDM_THEME_TARGET"
fi

if [ -d "$SDDM_THEME_SRC" ]; then
    echo "Copying theme to $SDDM_THEME_TARGET"
    sudo cp -r "$SDDM_THEME_SRC" "$SDDM_THEME_TARGET"
else
    echo "Warning: $SDDM_THEME_SRC not found!"
fi

echo ">>> Done!"
