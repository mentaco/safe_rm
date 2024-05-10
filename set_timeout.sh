#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$0")"

TARGET_FILE="./timeout"
NOHUP_PID_FILE="$1"
BACKUP_DIR="$2"
PATH_RECORD="$3"
NEW_TIME="$4"

if [ -f "${TARGET_FILE}" ]; then
    if [ "$(uname)" == 'Darwin' ]; then
        sed -i "" "s/^TIMEOUT=.*/TIMEOUT=${NEW_TIME}/" "${TARGET_FILE}"   # macOS
    elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
        sed -i "s/^TIMEOUT=.*/TIMEOUT=${NEW_TIME}/" "${TARGET_FILE}"   # Linux
    fi
else
    echo "TIMEOUT=${NEW_TIME}" > "${TARGET_FILE}"
fi
echo "Set TIMEOUT to ${NEW_TIME} [min]."

# Restart delete_old_files
if [ -f "${NOHUP_PID_FILE}" ]; then
    pid="$(cat "${NOHUP_PID_FILE}")"
    if ps -p "${pid}" > /dev/null; then
        process_name="$(ps -p "${pid}" -o args)"
        if [[ "${process_name}" == *"delete_old_files"* ]]; then
            kill -KILL "${pid}"
            nohup ./delete_old_files.sh "${BACKUP_DIR}" "${PATH_RECORD}" > /dev/null &
            echo "$!" > "${NOHUP_PID_FILE}"
            echo "Restart delete program."
        fi
    fi
fi
