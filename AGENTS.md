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
### Ignore Heavy Directories (Unless Instructed)

These dirs contain too many files. **Exclude them** from `find`, `fd`, `rg`, `grep`, etc. unless I explicitly ask you to edit them:

- `./dot_local/share/fonts/`
- `./dot_local/share/icons/`
- `./dot_local/share/themes/`
- `./dot_fonts`
- `./dot_icons`
- `./dot_themes`

Example: `fd --exclude 'dot_local/share/fonts' --exclude 'dot_local/share/icons' --exclude 'dot_local/share/themes'`

Example: `rg -g '!dot_local/share/fonts' -g '!dot_local/share/icons'`

### Config Location
Most app configs live under `./dot_config/`. Example: `./dot_config/foot/`, `./dot_config/kitty/`, `./dot_config/zsh/`.

### Flatpak Stuff
Flatpak apps store their permissions data at `./dot_local/share/private_flatpak/`. Flapak app data is stored in `./dot_var/app/`.

### Chezmoi
This is a chezmoi repo. Files under `dot_*` are synced to `~/.<name>` on my system. Don't touch the actual home directory files — edit the dotfiles instead.

Chezmoi manages files a bit differently:
- To make files executable the prefix `executable_` must be added to the file name ie `executable_fileName.extension`.
- To make a hidden file/folder prefix `dot_`
- To make a file/folder private prefix `private_`

### Scripts
When writing `bash`, `sh`, and `zsh` scripts there is no need to check for dependencies, you must assume that they exist on the host system.
