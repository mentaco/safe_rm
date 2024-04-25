#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$0")"

function show_list() {
   TARGET_DIR="$1"

    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Backup directory does not exist."
        return
    fi

    local files=($(find "${TARGET_DIR}" -maxdepth 1))

    echo -e "Backup directory is ${TARGET_DIR}\n"

    ls -p "${TARGET_DIR}"
}

show_list $1
