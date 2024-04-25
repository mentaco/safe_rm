#!/bin/bash

set -uo pipefail

trap 'exit 0' SIGTERM

cd "$(dirname -- "$0")"

TARGET_DIR="./backup"
TIMEOUT=1
LOOP_TIME=10

function delete_file() {
    if [ ! -d "${TARGET_DIR}" ]; then
        return
    fi

    local files=($(find "${TARGET_DIR}" -maxdepth 1 -cmin +"${TIMEOUT}"))

    for item in "${files[@]}"; do
        if [ "${item}" != "${TARGET_DIR}" ]; then
            rm -rf "${item}"
        fi
    done
}

while true; do
    delete_file
    sleep "${LOOP_TIME}"
done
