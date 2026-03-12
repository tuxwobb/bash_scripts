#!/bin/bash

set -euo pipefail

ATTACH=0
SESSIONS=()

HELP="tmux create and attach script
  name1 name2 ... - create sessions name1 name2 ...
  -f | --file [file] - create session from [file]
  -a | --attach - attach created session
  -d | --default - create default sessions 
  -h | --help - manual page"

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

# function to print help instructions
print_help() {
  echo -e "$HELP"
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
  print_help
  exit 0
fi

# parse parameters
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    print_help
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
