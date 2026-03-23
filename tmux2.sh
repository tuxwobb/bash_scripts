#!/bin/bash

set -euo pipefail

ATTACH='false'
USE_DEFAULT_SESSIONS='false'
DEFAULT_SESSIONS=('admin' 'devel' 'task' 'email' 'news')
VERBOSE='false'
SESSIONS=()

# function to show help
usage() {
  echo "Usage: $0 [-h] [-va] [-d] [-f FILE] [SESSION] [SESSION...]"
  echo "  Script to create and attach tmux sessions"
  echo "    -h       man page"
  echo "    -v       verbose output"
  echo "    -a       attach created session"
  echo "    -d       create default set of sessions"
  echo "    -f FILE  create session from file"
  echo
  exit 1
}

# function to log output
log() {
  local MESSAGE="${*}"
  echo "$MESSAGE"
}

# function to read sessions from file
read_sessions_from_file() {
  if [[ $VERBOSE == 'true' ]]; then
    log "Reading sessions from file..."
  fi
  local FILE="$1"

  if [[ -n $FILE ]]; then
    if [[ ! -f "$FILE" ]]; then
      log "FILE '$FILE' not found."
    fi

    while IFS= read -r session; do
      [[ -z "$session" ]] && continue
      SESSIONS+=("$session")
    done <"$FILE"
  fi
}

# function to create new session
create_session() {
  if [[ $(tmux has-session -t "$1" &>/dev/null) ]]; then
    log "session $1 already exists"
  else
    tmux new-session -d -s "$1" &>/dev/null
    log "session $1 created"
  fi
}

# function to attach session
attach_session() {
  if [[ $ATTACH == 'true' ]]; then
    if [[ $VERBOSE == 'true' ]]; then
      log "Attaching to last session..."
    fi
    tmux attach
  fi
}

# print usage in case of no arguments
if [[ $# -eq 0 ]]; then
  usage
fi

# parse parameters
while getopts haf:dv OPTION; do
  case $OPTION in
  h) # print usage
    usage
    ;;
  a) # attach session
    ATTACH='true'
    ;;
  f) # read from file
    read_sessions_from_file "$OPTARG"
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
  SESSIONS+=("$1")
  shift
done

# create sessions from array
if [[ $VERBOSE == 'true' ]]; then
  log "Creating sessions..."
fi

if [[ $USE_DEFAULT_SESSIONS == 'true' ]]; then
  for session in "${DEFAULT_SESSIONS[@]}"; do
    create_session "$session"
  done
else
  for session in "${SESSIONS[@]}"; do
    create_session "$session"
  done
fi

# attach to last session in case of -a parameter
attach_session
