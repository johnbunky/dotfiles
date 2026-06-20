#!/usr/bin/env bash
# scripts/link.sh — symlink dotfiles configs into place
# Safe to re-run: backs up any existing real file before linking.
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

link() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        # Already a symlink, just relink in case target moved
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "==> Backing up existing $dest"
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    fi

    ln -s "$src" "$dest"
    echo "==> Linked $dest -> $src"
}

link "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
link "$DOTFILES_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"

if [ -f "$DOTFILES_DIR/kitty/kitty.conf" ]; then
    link "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
fi

echo "==> Done. Existing configs backed up to $BACKUP_DIR (if any)."
echo "==> From now on, edit files inside $DOTFILES_DIR directly — changes apply immediately."
