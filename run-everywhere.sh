#!/bin/bash

set -o pipefail

SERVER_FILE='servers'

# Usage function
usage() {
  echo "Usage: $0 [-f FILE] [-n] [-s] [-v] COMMAND"
  echo "  Script to run command on remote machines, default list of servers in file servers"
  echo "    -f FILE  custom file with list of servers"
  echo "    -n       dry-run"
  echo "    -s       run as sudo"
  echo "    -v       verbose mode"
  echo
  exit 0
}

# Parsing arguments
while getopts f:nsv OPTION; do
  case "$OPTION" in
  f)
    SERVER_FILE=$OPTARG
    ;;
  n)
    DRY_RUN='true'
    ;;
  s)
    SUDO='true'
    ;;
  v)
    VERBOSE='true'
    ;;
  *)
    usage
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ $# -eq 0 ]]; then
  usage
fi

if [[ UID -eq 0 ]]; then
  echo "Script must be executed under normal user." >&2
  exit 1
fi

if [[ ! -e $SERVER_FILE ]]; then
  echo "File $SERVER_FILE does not exist." >&2
  exit 1
fi

# Main loop

# create command
COMMAND='set -o pipefail; '
if [[ $SUDO == 'true' ]]; then
  COMMAND+='sudo '
fi
COMMAND+="$*"

while read -r SERVER PORT; do
  # verbose output
  if [[ $VERBOSE == 'true' ]]; then
    echo ">>> ${SERVER}"
  fi

  # dry-run
  if [[ $DRY_RUN == 'true' ]]; then
    echo "ssh -n $SERVER $PORT $COMMAND"
  else
    ssh -n "$SERVER" -p "$PORT" "$COMMAND"
    if [[ "${?}" -ne 0 ]]; then
      echo "Command was not successful." >&2
    fi
  fi

done <"$SERVER_FILE"

exit 0
