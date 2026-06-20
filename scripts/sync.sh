#!/usr/bin/env bash
# scripts/sync.sh — regenerate package lists and commit changes
# Run this after installing/removing packages to keep dotfiles current.
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

echo "==> Regenerating package lists"
pacman -Qqe > pacman/pkglist.txt
pacman -Qqem > pacman/aur-pkglist.txt

if git diff --quiet && git diff --cached --quiet; then
    echo "==> No changes since last sync"
    exit 0
fi

echo "==> Changes detected:"
git diff --stat

read -p "Commit and push? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git add .
    git commit -m "sync: $(date +%Y-%m-%d)"
    git push
    echo "==> Synced."
else
    echo "==> Skipped commit. Changes left staged in working tree."
fi
