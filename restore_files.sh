#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$0")"

TARGET_DIR="./backup"
PATH_RECORD="./.paths"

function restore_file() {
    local target_idx="$1"

    IFS=" "
    local idx=1
    while read original backup; do
        echo "${original}"
        if [ "${target_idx}" -eq "${idx}" ]; then
            eval mv -i "${backup}" "${original}"
            return
        fi
        ((++idx))
    done < "${PATH_RECORD}"
}

sorted_num="$(sort -nr <<< "$@")"

for num in "${sorted_num}"; do
    restore_file "${num}"
    sed -i "" ${num}d "${PATH_RECORD}"
done
