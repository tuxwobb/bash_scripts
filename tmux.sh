#!/bin/bash

set -euo pipefail

ATTACH=0
SESSIONS=()

# function to show help
usage() {
  echo "Usage: $0 [-f [FILE]] [-a] [-d] [-h] [SESSION] [SESSION...]"
  echo "  Script to create tmux sessions"
  echo "  -f | --file [FILE] create session from file"
  echo "  -a | --attach      attach created session"
  echo "  -d | --default     create default set of sessions"
  echo "  -h | --help        man page"
  echo 
  exit 1
}

# function to read sessions from file
read_sessions_from_file() {
  local file="$1"

  if [[ -n $file ]]; then
    if [[ ! -f "$file" ]]; then
      echo "File '$file' not found."
    fi

    while IFS= read -r session; do
      [[ -z "$session" ]] && continue
      SESSIONS+=("$session")
    done <"$file"
  fi
}

# function to create new session
create_session() {
  local name="$1"

  if [[ $(tmux ls | grep -c "$name") -gt 0 ]]; then
    echo "session $name already exists"
  else
    tmux new-session -d -s "$name"
    echo "session $name created"
  fi
}

# function to attach session
attach_session() {
  if [[ $ATTACH -ne 0 ]]; then
    echo "attaching to last session..."
    tmux attach
  fi
}

# print help in case of no argument
if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

# parse parameters
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  -a | --attach)
    ATTACH=1
    shift
    ;;
  -f | --file)
    read_sessions_from_file "$2"
    shift 2
    ;;
  -d | --default)
    SESSIONS=("admin" "devel" "email" "news" "ssh")
    ATTACH=1
    shift
    ;;
  *)
    SESSIONS+=("$1")
    shift
    ;;
  esac
done

# create sessions from array
for session in "${SESSIONS[@]}"; do
  create_session "$session"
done

# attach to last session in case of -a parameter
attach_session
