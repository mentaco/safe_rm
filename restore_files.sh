#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$0")"

TARGET_DIR="$1"
PATH_RECORD="$2"
shift
shift

function restore_file() {
    local target_idx="$1"

    IFS=" "
    local idx=1
    while read original backup; do
        if [ "${target_idx}" -eq "${idx}" ]; then
            eval mv -i "${backup}" "${original}"
            return
        fi
        ((++idx))
    done < "${PATH_RECORD}"
}

args=("$@")
sorted_num=($(printf "%d\n" "${args[@]}"| sort -nr))
for num in "${sorted_num[@]}"; do
    restore_file "${num}"
    sed -i "" ${num}d "${PATH_RECORD}"
done
