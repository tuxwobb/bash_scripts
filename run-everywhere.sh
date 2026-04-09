#!/bin/bash

SERVER_FILE='servers'

# Usage function
usage() {
  echo "Usage: $0 [-f FILE] [-dsv] COMMAND"
  echo "  Script to run command on remote machines, default list of servers in file servers, format server port"
  echo "    -f FILE  custom file with list of servers"
  echo "    -d       dry-run"
  echo "    -s       run as sudo"
  echo "    -v       verbose mode"
  echo
  exit 0
}

# Parsing arguments
while getopts f:dsv OPTION; do
  case "$OPTION" in
  f)
    SERVER_FILE=$OPTARG
    ;;
  d)
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

if [[ $UID -eq 0 ]]; then
  echo "You can't use sudo, use option -s instead." >&2
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
    echo "ssh -n $SERVER -p $PORT $COMMAND"
  else
    if ! ssh -n "$SERVER" -p "$PORT" "$COMMAND"; then
      echo "Command was not successful." >&2
    fi
  fi

done <"$SERVER_FILE"

exit 0
