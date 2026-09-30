# AGENTS.md — Linux Dotfiles Agent Instructions
This repo is my Linux dotfiles, managed via **chezmoi**. Read this before doing anything.

## Repo Layout
```
dot_config/    — chezmoi managed configs (mostly here)
dot_fonts/     — symlinked font configs
dot_icons/     — symlinked icon theme configs
dot_local/     — local data / app-specific stuff
dot_themes/    — symlinked theme configs
dot_var/       — flatpak app data
```

## Key Directives
### 1. Ignore Heavy Directories (Unless Instructed)

These dirs contain too many files. **Exclude them** from `find`, `fd`, `rg`, `grep`, etc. unless I explicitly ask you to edit them:

- `./dot_local/share/fonts/`
- `./dot_local/share/icons/`
- `./dot_local/share/themes/`
- `./dot_fonts`
- `./dot_icons`
- `./dot_themes`

Example: `fd --exclude 'dot_local/share/fonts' --exclude 'dot_local/share/icons' --exclude 'dot_local/share/themes'`

Example: `rg -g '!dot_local/share/fonts' -g '!dot_local/share/icons'`

### 2. Config Location
Most app configs live under `./dot_config/`. Example: `./dot_config/foot/`, `./dot_config/kitty/`, `./dot_config/zsh/`.

### 3. Flatpak Stuff
Flatpak apps store their permissions data at `./dot_local/share/private_flatpak/`. Flapak app data is stored in `./dot_var/app/`.

### 4. Chezmoi
This is a chezmoi repo. Files under `dot_*` are synced to `~/.<name>` on my system. Don't touch the actual home directory files — edit the dotfiles instead.
