#!/usr/bin/env bash
# post-install.sh — power management + thermal tuning
# Resolves the power-profiles-daemon / TLP conflict discovered during setup.
set -e

echo "==> Masking power-profiles-daemon (conflicts with TLP)"
sudo systemctl mask power-profiles-daemon
sudo systemctl stop power-profiles-daemon 2>/dev/null || true

echo "==> Enabling thermald and TLP"
sudo systemctl enable --now thermald
sudo systemctl enable --now tlp

echo "==> Enabling ollama service"
sudo systemctl enable --now ollama

echo "==> Cleaning orphaned packages"
orphans=$(pacman -Qdtq || true)
if [ -n "$orphans" ]; then
    sudo pacman -Rns --noconfirm $orphans
fi

echo "==> Power/thermal tuning complete"
sudo tlp-stat -t || true
