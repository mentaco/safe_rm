#!/bin/bash

set -uo pipefail

trap 'exit 0' SIGTERM

cd "$(dirname -- "$0")"

TARGET_DIR="./backup"
PATH_RECORD="./.paths"
TIMEOUT=1
LOOP_TIME=10

function delete_path_record() {
    local idx=1

    while read _ backup; do
        if [ "$(basename "${backup}")" = "$(basename "$1")" ]; then
            break
        fi
        ((++idx))
    done
    
    sed -i "" ${idx}d "${PATH_RECORD}"
}

function delete_file() {
    if [ ! -d "${TARGET_DIR}" ]; then
        return
    fi

    local files=($(find "${TARGET_DIR}" -maxdepth 1 -cmin +"${TIMEOUT}"))

    if [ "${#files[@]}" == 0 ]; then
        return
    fi

    for item in "${files[@]}"; do
        if [ "${item}" != "${TARGET_DIR}" ]; then
            rm -rf -- "${item}"
            delete_path_record "${item}"
        fi
    done
}

while true; do
    delete_file
    sleep "${LOOP_TIME}"
done
