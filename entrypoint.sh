#!/usr/bin/env bash

function spawn {
    if [[ -z ${PIDS+x} ]]; then PIDS=(); fi
    "$@" &
    PIDS+=($!)
}

function join {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            wait "${pid}"
        done
    fi
}

function on_kill {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            kill "${pid}" 2> /dev/null
        done
    fi
    kill "${ENTRYPOINT_PID}" 2> /dev/null
}

function log {
    local LEVEL="$1"
    local MSG="$(date '+%D %T') [${LEVEL}] $2"
    case "${LEVEL}" in
        INFO*)      MSG="\x1B[94m${MSG}";;
        WARNING*)   MSG="\x1B[93m${MSG}";;
        ERROR*)     MSG="\x1B[91m${MSG}";;
        *)
    esac
    echo -e "${MSG}"
}

export ENTRYPOINT_PID="${BASHPID}"

trap "on_kill" EXIT
trap "on_kill" SIGINT

if [[ -n "${ARIA2_PORT}" ]]; then
    spawn aria2c --enable-rpc --disable-ipv6 --rpc-listen-all --rpc-listen-port="${ARIA2_PORT}"
    log "INFO" "Spawn aria2c"
    ARIA2_ENABLED="true"
fi

if [[ "${ARIA2_ENABLED}" == "true" && -n "${ARIA2_UP}" ]]; then
    spawn "${ARIA2_UP}"
    log "INFO" "Spawn aria2 up script: ${ARIA2_UP}"
fi

if [[ $# -gt 0 ]]; then
    "$@"
fi

if [[ $# -eq 0 || "${DAEMON_MODE}" == true ]]; then
    join
fi
