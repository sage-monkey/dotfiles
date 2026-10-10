#!/usr/bin/env zsh

set -euo pipefail

readonly WALLPAPER_CACHE_DIR="$HOME/.cache/monkey"
mkdir -p "$WALLPAPER_CACHE_DIR"

main() {
    local wallpaper_path="${1:-}"

    if [[ -n "$wallpaper_path" ]]; then
        if [[ ! -f "$wallpaper_path" ]]; then
            echo "Error: File '$wallpaper_path' not found." >&2
            exit 1
        fi

        pkill -x swaybg 2>/dev/null || true
        cp --force "$wallpaper_path" "$WALLPAPER_CACHE_DIR/wallpaper"
        local background_color
        background_color="$(extract_bg_color "$wallpaper_path")"
        swaybg -i "$WALLPAPER_CACHE_DIR/wallpaper" -m fit -c "$background_color" & disown

        pkill -x swayidle 2>/dev/null || true
        magick "$wallpaper_path" -adaptive-blur 0x8 "$WALLPAPER_CACHE_DIR/wallpaper_blurred"
        swayidle -w timeout 240 'niri msg action power-off-monitors' \
            timeout 300 "swaylock -s fit -c \"$background_color\" --image \"$WALLPAPER_CACHE_DIR/wallpaper_blurred\""
    else
        local wallpaper_cached="$WALLPAPER_CACHE_DIR/wallpaper"
        local wallpaper_blurred="$WALLPAPER_CACHE_DIR/wallpaper_blurred"

        if [[ -f "$wallpaper_cached" && -f "$wallpaper_blurred" ]]; then
            pkill -x swaybg 2>/dev/null || true
            pkill -x swayidle 2>/dev/null || true
            local background_color
            background_color="$(extract_bg_color "$wallpaper_cached")"
            swaybg -i "$wallpaper_cached" -m fit -c "$background_color" & disown
            swayidle -w timeout 240 'niri msg action power-off-monitors' \
                timeout 300 "swaylock -s fit -c \"$background_color\" --image \"$wallpaper_blurred\""
        else
            echo "Usage: $0 <path_to_wallpaper>" >&2
            echo "Error: No file provided and cache is missing." >&2
            exit 1
        fi
    fi
}

extract_bg_color() {
    local image_path="$1"
    convert "$image_path" -resize 1x1 txt:- | rg -o '#[[:xdigit:]]{6}' | cut -c 2-
}

main "$@"