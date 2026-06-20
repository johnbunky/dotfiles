# dotfiles

Personal Arch Linux setup — ThinkBook 14 G2 (i5-1135G7, Iris Xe).

Captures everything from the original install so a reinstall is `git clone` + `./install.sh` instead of a two-day rebuild.

## Usage

On a fresh Arch install (post `archinstall`, base system + network configured):

```bash
git clone git@github.com:johnbunky/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh scripts/post-install.sh
./install.sh
```

## What this sets up

- **fish** shell as default, with proper `fish_add_path` for npm-global
- **Hyprland** config (minimal starter — keybinds for terminal, launcher, fullscreen, exit)
- **kitty** terminal config (if present)
- **ollama** with Vulkan iGPU offload enabled (`OLLAMA_IGPU_ENABLE=1`) — required because
  ollama drops integrated GPUs by default; needs `ollama-vulkan` package, not plain `ollama`
- **TLP + thermald** for power/thermal management — note: conflicts with GNOME's
  `power-profiles-daemon`, which must be masked (not just disabled) or it gets reactivated
  via D-Bus and silently breaks TLP startup
- Package lists for `pacman -S` and `yay -S` to restore the full environment

## Daily workflow

Configs (`fish/config.fish`, `hypr/hyprland.conf`, etc.) are **symlinked** from `~/.config/...`
into this repo via `scripts/link.sh`. Editing the file in either location edits the same
underlying file — there's no copy step. Commit changes normally whenever you want to snapshot:

```bash
cd ~/dotfiles
git add .
git commit -m "tweak fish prompt"
git push
```

Package lists (`pacman/pkglist.txt`, `pacman/aur-pkglist.txt`) are **not** symlinked — they're
a snapshot of installed packages and don't update themselves. Run `scripts/sync.sh` after any
`pacman -S` / `yay -S` / removal session to regenerate them; it shows a diff and asks before
committing+pushing:

```bash
~/dotfiles/scripts/sync.sh
```

Rule of thumb: edit configs anytime, commit anytime. Run `sync.sh` after install sessions, not
on every commit.

## Known gotchas (learned the hard way)

- `ollama` (plain) ships CPU-only backends on Arch — use `ollama-vulkan` from extra repo instead
- `power-profiles-daemon` auto-restarts via D-Bus activation even after `systemctl disable`;
  must `mask` it, not just stop/disable
- fish config needs `fish_add_path`, not bash-style `export PATH=...`
- npm global installs need `~/.npm-global` prefix set to avoid `EACCES` on `/usr/lib`
- Chrome can leave a stale `SingletonLock` after an unclean shutdown — `chrome-fix` alias
  in fish config clears it

## Structure

```
dotfiles/
├── install.sh                          # bootstrap script
├── fish/config.fish                    # shell config + npm path + chrome-fix alias
├── hypr/hyprland.conf                  # minimal Hyprland keybinds
├── kitty/kitty.conf                    # terminal config (if customized)
├── systemd-overrides/ollama-igpu.conf  # Vulkan iGPU enable override
├── pacman/pkglist.txt                  # official repo packages
├── pacman/aur-pkglist.txt              # AUR packages
└── scripts/post-install.sh             # TLP/thermald/power-profiles-daemon/cleanup
```
