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

echo "==> Symlinking configs (fish, hyprland, kitty)"
chmod +x "$DOTFILES_DIR/scripts/link.sh"
"$DOTFILES_DIR/scripts/link.sh"

echo "==> Applying ollama iGPU override (Vulkan offload for Intel iGPUs)"
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp "$DOTFILES_DIR/systemd-overrides/ollama-igpu.conf" /etc/systemd/system/ollama.service.d/override.conf
sudo systemctl daemon-reload

echo "==> Running post-install tuning (TLP, thermald, power-profiles-daemon mask)"
bash "$DOTFILES_DIR/scripts/post-install.sh"

echo "==> Cloning nvim config"
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone git@github.com:johnbunky/nvimTermuxJavaIDE.git "$HOME/.config/nvim"
else
    echo "    ~/.config/nvim already exists, skipping clone"
fi

echo "==> Cloning terminal_jk / terminal_ai"
if [ ! -d "$HOME/terminal_jk" ]; then
    git clone git@github.com:johnbunky/terminal_jk.git "$HOME/terminal_jk"
else
    echo "    ~/terminal_jk already exists, skipping clone"
fi

echo "==> Restoring global npm packages"
if [ -s "$DOTFILES_DIR/npm/global-packages.txt" ]; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    xargs npm install -g < "$DOTFILES_DIR/npm/global-packages.txt"
fi

echo "==> Setting fish as default shell"
chsh -s /usr/bin/fish

echo "==> Reminder: create ~/.config/terminal_ai/keys.env manually (see README — secrets are never stored in this repo)"
echo "==> Reminder: run 'ssh-keygen' and add the new public key to GitHub manually"

echo "==> Done. Reboot recommended."
