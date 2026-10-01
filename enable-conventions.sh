#!/usr/bin/env bash

set -eu

readonly SCRIPT_DIR="/opt/sye-provisioning"
readonly USER_FILE="${SCRIPT_DIR}/users.conf"
readonly SUDOERS_FILE="${SCRIPT_DIR}/sudoers.conf"

log() {
    printf "[INFO] %s\n" "$1"
}

die() {
    printf "[ERROR] %s\n" "$1" >&2
    exit 1
}

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        die "This script must be run as root."
    fi
}

create_users() {
    if [[ ! -f "$USER_FILE" ]]; then
        die "User file not found: $USER_FILE"
    fi

    while IFS='|' read -r username ssh_key; do

        if [[ -z "$username" ]]; then
            continue
        fi

        if [[ "$username" == \#* ]]; then
            continue
        fi

        log "Creating user: ${username}."

        if ! id "$username" &>/dev/null; then
            useradd -m -s /bin/bash "$username"
            log "User ${username} created."
        else
            log "User ${username} already exists. Skipping creation."
        fi

        log "Setting up SSH key for user: ${username}."
        local ssh_dir="/home/${username}/.ssh"

        mkdir -p "$ssh_dir"
        touch "${ssh_dir}/authorized_keys"
        chmod 700 "$ssh_dir"
        chmod 600 "${ssh_dir}/authorized_keys"

        chown -R "${username}:${username}" "$ssh_dir"

        if [[ -n "$ssh_key" ]]; then
            if ! grep -qxF "$ssh_key" "${ssh_dir}/authorized_keys"; then
                echo "$ssh_key" >> "${ssh_dir}/authorized_keys"
                log "SSH key added for user ${username}."
            else
                log "SSH key already exists for user ${username}. Skipping."
            fi
        fi

    done < "$USER_FILE"
}

main() {
    require_root
    echo "=== Setting up server conventions ==="

    log "Creating users from ${USER_FILE} ..."
    create_users
}

main
