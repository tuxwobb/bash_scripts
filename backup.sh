#!/bin/bash

# default backup directory
DESTINATION='/tmp'

usage() {
  echo "Usage: $0 [-d DESTINATION] FILE|DIRECTORY [FILE|DIRECTORY...]" >&2
  echo "  script to backup selected files/directories with timestamps" >&2
  exit 1
}

log() {
  echo "$1"
  logger -t "$0" "$1"
}

backup_file() {
  # function to backup file or directory into $DESTINATION directory
  local SOURCE=$1
  local DEST=${DESTINATION}/$(basename $SOURCE)-$(date +%F-%N)

  # backup file
  if [[ -f "$SOURCE" ]]; then
    if cp -p "$SOURCE" "$DEST" &>/dev/null; then
      log "Backup of file $SOURCE into folder $(dirname "$DEST") was successfull!"
      return 0
    else
      log "Backup of file $SOURCE into folder $(dirname "$DEST") failed!"
    fi

  # backup directory
  elif [[ -d "$SOURCE" ]]; then
    if cp -pr "$SOURCE" "$DEST" &>/dev/null; then
      log "Backup of directory $SOURCE into folder $(dirname "$DEST") was successfull!"
      return 0
    else
      log "Backup of directory $SOURCE into folder $(dirname "$DEST") failed!"
    fi

  # operation not successfull
  else
    log "File or directory $SOURCE does not exist!" >&2
    return 1
  fi
}

# test if argument was provided
if [[ $# -eq 0 ]]; then
  usage
fi

# main
while getopts d: OPTION; do
  case $OPTION in
  d)
    DESTINATION="$OPTARG"
    if mkdir -p "$DESTINATION" &>/dev/null; then
      log "Created new directory $DESTINATION"
    else
      log "Error while creating directory $DESTINATION" >&2
      exit 1
    fi
    ;;
  *)
    usage
    ;;
  esac
done

shift "$((OPTIND - 1))"

while [[ ${#} -gt 0 ]]; do
  backup_file "$1"
  shift
done
