#!/bin/bash

set -euo pipefail

function show_help() {
    echo "This command backs up the specified files and deletes them."
    echo "Usage: $0 [file ...]"
    echo "  or   $0 [option]"
    echo "Options:"
    echo "  --help, -h  Display this help massage."
    echo "  start       Start a process to automatically delete old backups."
    echo "  stop        Stop the above process."
    echo "  list        Show the files present in the backup directory."
    echo "  restore     Restore files with specified index."
    echo "              Takes integer as argument."
}

BACKUP_DIR="./backup"
NOHUP_PID_FILE="./.pid"
PATH_RECORD="./.path_list"

if [ "$#" -le 0 ]; then
    echo "Error: Missing arguments."
    show_help
    exit 1

elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0

elif [ "$1" = "start" ]; then
    cd "$(dirname -- "$(realpath "$0")")"
    if [ -f "${NOHUP_PID_FILE}" ]; then
        pid="$(cat "${NOHUP_PID_FILE}")"
        if ps -p "${pid}" > /dev/null; then
            process_name="$(ps -p "${pid}" -o args)"
            if [[ "${process_name}" == *"delete_old_files"* ]]; then
                echo "The process is already running."
                exit 1
            fi
        fi
    fi

    nohup ./delete_old_files.sh "${BACKUP_DIR}" "${PATH_RECORD}" > /dev/null &
    echo "$!" > "${NOHUP_PID_FILE}"
    exit 0

elif [ "$1" = "stop" ]; then
    cd "$(dirname -- "$(realpath "$0")")"
    pid="$(cat "${NOHUP_PID_FILE}")"
    if ! ps -p "${pid}" > /dev/null; then
        echo "Process is not running."
        exit 1
    fi

    pid="$(cat "${NOHUP_PID_FILE}")"
    kill -KILL "${pid}"

    echo "Stoped process."
    exit 0

elif [ "$1" = "list" ]; then
    cd "$(dirname -- "$(realpath "$0")")"
    ./show_list.sh "${BACKUP_DIR}" "${PATH_RECORD}"
    exit 0

elif [ "$1" = "restore" ]; then
    shift
    cd "$(dirname -- "$(realpath "$0")")"
    ./restore_files.sh "${BACKUP_DIR}" "${PATH_RECORD}" "$@"
    exit 0

else
    FILES=()
    for item; do
        FILES+=("$(realpath "${item}")")
    done

    cd "$(dirname -- "$(realpath "$0")")"
    ./move_files.sh "${BACKUP_DIR}" "${PATH_RECORD}" "${FILES[@]}"
    exit 0
fi
