#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$0")"

function show_list() {
    TARGET_DIR="$1"
    PATH_RECORD="$2"

    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Backup directory does not exist."
        return
    fi

    local files=($(find "${TARGET_DIR}" -maxdepth 1))

    echo -e "Backup directory is ${TARGET_DIR}\n"

    echo "[  Original  Backup  ]"

    IFS=" "
    local idx=0
    while read original backup; do
        echo ""${idx}"  "${original}"  "$(basename "${backup}")""
        ((++idx))
    done < "${PATH_RECORD}"

    echo ""
    echo "If you want to restore files, enter the file number in the command."
    echo "Example: srm restore 3 4"
}

show_list "$@"
