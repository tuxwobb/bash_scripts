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

if [[ ! -e $SERVER_FILE ]]; then
  echo "File $SERVER_FILE does not exist."
  exit 1
fi

# Main loop
COMMAND="$*"

while read -re LINE; do
  # verbose output
  if [[ $VERBOSE == 'true' ]]; then
    echo ">>> ${LINE}"
  fi

  # dry-run
  if [[ $DRY_RUN == 'true' ]]; then
    echo "ssh $LINE $COMMAND"
  else
    ssh -n "$LINE" "$COMMAND"
  fi

done <"$SERVER_FILE"

exit 0
