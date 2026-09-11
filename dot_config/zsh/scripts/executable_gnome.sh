#!/usr/bin/env sh

set -oue pipefail

GNOME_PATH=$HOME/.config/zsh/misc/gnome

echo "Applying gnome settings"
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$GNOME_PATH/media-keys.bak"
dconf load /org/gnome/shell/keybindings/ < "$GNOME_PATH/shell-keybindings.bak"
dconf load /org/gnome/desktop/wm/keybindings/ < "$GNOME_PATH/wm-keybindings.bak"
dconf load /org/gnome/mutter/keybindings/ < "$GNOME_PATH/mutter-keybindings.bak"
dconf load /org/gnome/mutter/wayland/keybindings/ < "$GNOME_PATH/wayland-keybindings.bak"
echo "Setting Applied"
