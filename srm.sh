#!/bin/bash

set -euo pipefail

cd "$(dirname -- "$(realpath "$0")")"

function show_help() {
    echo "This command backs up the specified files and deletes them."
    echo "Usage: $0 [file ...]"
    echo "  or   $0 [option]"
    echo "Options:"
    echo "  --help, -h  Display this help massage."
    echo "  start       Start a process to automatically delete old backups."
    echo "  stop        Stop the above process."
    echo "  list        Show the files present in the backup directory."
}


BACKUP_DIR="./backup"
NOHUP_PID_FILE="./.pid"
PATH_RECORD="./.paths"

if [ "$#" -le 0 ]; then
    echo "Error: Missing arguments."
    show_help
    exit 1
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
elif [ "$1" = "start" ]; then
    if [ -f "${NOHUP_PID_FILE}" ]; then
        echo "The process is already running."
        exit 1
    fi
    nohup ./delete_old_files.sh > /dev/null &
    echo "$!" > "${NOHUP_PID_FILE}"
    exit 0
elif [ "$1" = "stop" ]; then
    if [ ! -f "${NOHUP_PID_FILE}" ]; then
        echo "Process is not running."
        exit 1
    fi

    pid="$(cat "${NOHUP_PID_FILE}")"
    kill -TERM "${pid}"

    rm "${NOHUP_PID_FILE}"
    echo "Stoped process."
    exit 0
elif [ "$1" = "list" ]; then
    ./show_list.sh "${BACKUP_DIR}"
    exit 0
fi


function mk_backup_dir() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        mkdir "${BACKUP_DIR}"
        echo "Make directory at ${BACKUP_DIR}"
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
move_file "$@"
