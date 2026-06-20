#!/usr/bin/env bash
# dotfiles bootstrap — johnbunky
# Run from inside the cloned dotfiles repo: ./install.sh
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing official packages"
sudo pacman -S --needed - < "$DOTFILES_DIR/pacman/pkglist.txt"

echo "==> Checking for yay (AUR helper)"
if ! command -v yay &> /dev/null; then
    echo "==> yay not found, building it"
    sudo pacman -S --needed --noconfirm base-devel git
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

echo "==> Installing AUR packages"
if [ -s "$DOTFILES_DIR/pacman/aur-pkglist.txt" ]; then
    yay -S --needed - < "$DOTFILES_DIR/pacman/aur-pkglist.txt"
fi

echo "==> Linking fish config"
mkdir -p ~/.config/fish
cp "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

echo "==> Linking Hyprland config"
mkdir -p ~/.config/hypr
cp "$DOTFILES_DIR/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf

if [ -f "$DOTFILES_DIR/kitty/kitty.conf" ]; then
    echo "==> Linking kitty config"
    mkdir -p ~/.config/kitty
    cp "$DOTFILES_DIR/kitty/kitty.conf" ~/.config/kitty/kitty.conf
fi

echo "==> Applying ollama iGPU override (Vulkan offload for Intel iGPUs)"
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp "$DOTFILES_DIR/systemd-overrides/ollama-igpu.conf" /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload

echo "==> Running post-install tuning (TLP, thermald, power-profiles-daemon mask)"
bash "$DOTFILES_DIR/scripts/post-install.sh"

echo "==> Setting fish as default shell"
chsh -s /usr/bin/fish

echo "==> Done. Reboot recommended."
