#!/bin/bash

set -euo pipefail

ATTACH='false'
USE_DEFAULT_SESSIONS='false'
DEFAULT_SESSIONS=('admin' 'devel' 'task' 'email' 'news')
VERBOSE='false'
SESSIONS=()

# usage
usage() {
  echo "Usage: ${0} [-h] [-va] [-d] [-f FILE] [SESSION] [SESSION]..."
  echo "  Script to create and attach tmux sessions."
  echo "    -h       man page"
  echo "    -v       verbose output"
  echo "    -a       attach tmux"
  echo "    -d       create default sessions (${DEFAULT_SESSIONS[*]})"
  echo "    -f FILE  create sessions from file"
  echo
  exit 1
}

# verbose output
log() {
  local MESSAGE="${*}"
  if [[ ${VERBOSE} == 'true' ]]; then
    echo "${MESSAGE}"
  fi
}

# read sessions from file
read_sessions_from_file() {
  log "Reading sessions from file..."
  local FILE="${1}"

  if [[ -n ${FILE} ]]; then
    if [[ ! -f "${FILE}" ]]; then
      log "FILE '${FILE}' not found."
    fi

    while IFS= read -r SESSION; do
      [[ -z "${SESSION}" ]] && continue
      SESSIONS+=("${SESSION}")
    done <"${FILE}"
  fi
}

# create new session
create_session() {
  echo "Creating session $1"
  if tmux has -t "${1}" 2>/dev/null; then
    echo "Session ${1} already exists" >&2
  else
    tmux new-session -d -s "${1}" &>/dev/null
    echo "Session ${1} created"
  fi
}

# attach session
attach_session() {
  if [[ ${ATTACH} == 'true' ]]; then
    log "Attaching to last session..."
    tmux attach &>/dev/null
  fi
}

# print usage in case of no arguments
if [[ ${#} -eq 0 ]]; then
  usage
fi

# parse parameters
while getopts haf:dv OPTION; do
  case ${OPTION} in
  h) # print usage
    usage
    ;;
  a) # attach session
    ATTACH='true'
    ;;
  f) # read from file
    read_sessions_from_file "${OPTARG}"
    ;;
  d) # defautl sessions
    USE_DEFAULT_SESSIONS='true'
    ;;
  v) # verbose output
    VERBOSE='true'
    ;;
  ?) # print usage
    usage
    ;;
  esac
done

shift "$((OPTIND - 1))"

# parse arguments
while [[ ${#} -gt 0 ]]; do
  SESSIONS+=("${1}")
  shift
done

# append default sessions in case of -d
if [[ ${USE_DEFAULT_SESSIONS} == 'true' ]]; then
  log "Appending default sessions..."
  for SESSION in "${DEFAULT_SESSIONS[@]}"; do
    SESSIONS+=("$SESSION")
  done
fi

# create sessions from array
log "Creating sessions..."
for SESSION in "${SESSIONS[@]}"; do
  create_session "${SESSION}"
done

# attach to last session in case of -a parameter
attach_session
