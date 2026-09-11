#!/usr/bin/env bash

set -oue pipefail

WALLPAPER_DIR=$HOME/.cache/monkey
mkdir -p "$WALLPAPER_DIR"

# Check if a file path is provided as an argument
if [ -n "${1:-}" ]; then
    WALLPAPER="$1"

    # Verify the file exists before proceeding
    if [[ ! -f "$WALLPAPER" ]]; then
        echo "Error: File '$WALLPAPER' not found."
        exit 1
    fi

    # Set wallpaper
    pkill -x swaybg || true
    BG_COLOR=$(convert "$WALLPAPER" -resize 1x1 txt:- | rg -o "#[[:xdigit:]]{6}" | cut -c 2-)
    cp --force "$WALLPAPER" "$WALLPAPER_DIR/wallpaper"
    swaybg -i "$WALLPAPER_DIR/wallpaper" -m fit -c "$BG_COLOR" & disown

    # Lockscreen is done afterwards to speed up time to wallpaper
    pkill -x swayidle || true
    magick "$WALLPAPER" -adaptive-blur 0x8 "$WALLPAPER_DIR/wallpaper_blurred"
    swayidle -w timeout 240 'niri msg action power-off-monitors' timeout 300 "swaylock -s fit -c \"$BG_COLOR\" --image \"$WALLPAPER_DIR/wallpaper_blurred\""

else
    # If no file is given, check if cache exists
    if [[ -f "$WALLPAPER_DIR/wallpaper" && -f "$WALLPAPER_DIR/wallpaper_blurred" ]]; then
        # Skip cp and blur, only run avg color
        pkill -x swaybg || true
        pkill -x swayidle || true
        BG_COLOR=$(convert "$WALLPAPER_DIR/wallpaper" -resize 1x1 txt:- | rg -o "#[[:xdigit:]]{6}" | cut -c 2-)
        swaybg -i "$WALLPAPER_DIR/wallpaper" -m fit -c "$BG_COLOR" & disown
        swayidle -w timeout 240 'niri msg action power-off-monitors' timeout 300 "swaylock -s fit -c \"$BG_COLOR\" --image \"$WALLPAPER_DIR/wallpaper_blurred\""

    else
        echo "Usage: $0 <path_to_wallpaper>"
        echo "Error: No file provided and cache is missing."
        exit 1
    fi
fi
