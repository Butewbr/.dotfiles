#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Installing user dotfiles with stow..."
stow --verbose --target="$HOME" --restow --no-folding .

echo ">>> Installing SDDM theme..."
SDDM_THEME_NAME="Sugar-Candy"   # change this to the folder name in your repo
SDDM_TARGET_DIR="/usr/share/sddm/themes/$SDDM_THEME_NAME"

if [ -d "$SDDM_TARGET_DIR" ]; then
    echo "Removing old SDDM theme at $SDDM_TARGET_DIR"
    sudo rm -rf "$SDDM_TARGET_DIR"
fi

echo "Copying theme to $SDDM_TARGET_DIR"
sudo cp -r "$DOTFILES_DIR/sddm/usr/share/sddm/themes/$SDDM_THEME_NAME" "$SDDM_TARGET_DIR"

echo ">>> Done!"
