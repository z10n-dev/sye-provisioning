#!/usr/bin/env bash

set -euo

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

main() {
    require_root
    echo "=== Setting up server conventions ==="

    log "Creating users from ${USER_FILE}..."
}
