#!/usr/bin/env bash
set -euo pipefail

# List all distrobox containers
list_containers() {
    podman ps -a --filter label=manager=distrobox --format '{{.Names}}'
}

# List running distrobox containers
list_running_containers() {
    podman ps --filter label=manager=distrobox --format '{{.Names}}'
}

# Remove a container
remove_container() {
    echo 'WARNING!!! This will stop and remove the selected container.'
    local container
    container=$(list_containers | fzf)
    echo "${container} is being removed."
    echo "y" | distrobox-stop "$container"
    echo "y" | distrobox-rm "$container"
}

# Stop a running container
stop_container() {
    local container
    container=$(list_running_containers | fzf)
    echo "${container} is being stopped."
    echo "y" | distrobox-stop "$container"
}

# Create a new container
create_container() {
    local distrobox_home="$HOME/Documents/Distrobox"

    # Ensure package cache volumes exist
    podman volume create --ignore --label package-cache arch_package_cache 2>/dev/null || true
    podman volume create --ignore --label package-cache debian_package_cache 2>/dev/null || true

    local -a container_variants=(
        'ghcr.io/ublue-os/arch-toolbox:latest'
        'quay.io/toolbx-images/debian-toolbox:unstable'
    )

    local -A variant_cache=(
        ['ghcr.io/ublue-os/arch-toolbox:latest']='arch_package_cache:/var/cache/pacman/pkg'
        ['quay.io/toolbx-images/debian-toolbox:unstable']='debian_package_cache:/var/cache/apt/archives'
    )

    local selected_variant
    selected_variant=$(printf '%s\n' "${container_variants[@]}" | fzf)

    local package_cache="${variant_cache[$selected_variant]}"

    local -a network_options=(
        '--network distrobox-external_network'
        '--network distrobox-external_network --network caddy-internal_network'
    )

    local selected_network
    selected_network=$(printf '%s\n' "${network_options[@]}" | fzf)

    local container_name
    read -rp 'Enter Container Name: ' container_name

    distrobox-create --name "$container_name" \
        --home "$distrobox_home/$container_name" \
        --image "$selected_variant" \
        --hostname "$container_name" \
        --volume "$package_cache":z \
        --volume /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:ro \
        --nvidia \
        --unshare-devsys \
        --unshare-groups \
        --unshare-process \
        --unshare-ipc \
        --unshare-netns \
        --unshare-all \
        --additional-flags "$selected_network"
}

# Clear package cache for a selected distro
clear_container_cache() {
    local -a distros=(
        'Arch'
        'Debian'
    )

    local -A distro_cache=(
        ['Arch']='arch_package_cache'
        ['Debian']='debian_package_cache'
    )

    echo 'WARNING THIS WILL DELETE ALL PACKAGE CACHE!!!'
    sleep 3

    local selected_distro
    selected_distro=$(printf '%s\n' "${distros[@]}" | fzf)

    local cache_volume="${distro_cache[$selected_distro]}"
    podman volume rm "$cache_volume"
    podman volume create --ignore --label package-cache "$cache_volume"
}

# List and enter a container
enter_container() {
    local container
    container=$(list_containers | fzf)
    distrobox-enter "$container"
}

# Main entry point
main() {
    if [[ $# -eq 0 ]]; then
        enter_container
        return 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            q|--quit)
                stop_container
                ;;
            rm|--remove)
                remove_container
                ;;
            rmc|--clear-cache)
                clear_container_cache
                ;;
            c|--create)
                create_container
                ;;
            *)
                echo "Unknown parameter: $1"
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
