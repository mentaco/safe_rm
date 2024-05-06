#!/bin/bash

set -euo pipefail

BACKUP_DIR="$1"
PATH_RECORD="$2"
shift
shift

FILES=("$@")

function mk_backup_dir() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        mkdir "${BACKUP_DIR}"
        echo "Make directory at "$(realpath "${BACKUP_DIR}")""
    fi
}

function record_path() {
    local path="$(realpath "$1" | sed "s|$HOME|~|")"
    local element="${path} $2"
    echo "${element}" >> "${PATH_RECORD}"
}

function move_file() {
    local date="$(date +%y%m%d_%R:%S)"

    for item; do
        if [ "${item}" = "--" ]; then
            continue
        fi

        local file="$(basename -- "${item}")"
        local backup_file="${BACKUP_DIR}/${file}_${date}"
        record_path "${item}" "${backup_file}"
        mv -- "${item}" "${backup_file}"
    done
}

mk_backup_dir
move_file "${FILES[@]}"
