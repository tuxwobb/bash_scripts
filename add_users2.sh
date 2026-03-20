#!/bin/bash

USERS=()
LENGTH=30
PASSWORD_FILE='pass.txt'
SPECIAL='false'
SPECIAL_CHARS='!@#$%^&*()_-+={[}]:;'

# Check root function
check_root() {
  if [[ $UID -ne 0 ]]; then
    echo "You must be root!"
    exit 1
  fi
}

# Usage function
usage() {
  echo "Usage $0 [-h] [-p FILE] [-P LENGTH] [-s] [-v] [-l] USER [USER...]"
  echo "  Script to add users into local system"
  echo "  -h        man page"
  echo "  -p FILE   password file"
  echo "  -P LENGTH password lentgh (default 30)"
  echo "  -s        add special character into password"
  echo "  -v        write log to standard output"
  echo "  -l        write log to syslog"
  echo
  exit 1
}

# Log message function
log() {
  MESSAGE="$*"
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "$MESSAGE"
  fi
  if [[ $LOG -eq 1 ]]; then
    logger -t "$0 ${MESSAGE}"
  fi
}

# Generate password
generate_password() {
  PASSWORD=$(date +%F%N${RANDOM}${RANDOM} | sha256sum | head -c"${LENGTH}")
  if [[ $SPECIAL == 'true' ]]; then
    PASSWORD=${PASSWORD}$(echo "$SPECIAL_CHARS" | fold -w1 | shuf | head -c1)
  fi
  echo "${PASSWORD}" | passwd -s "$1"
  echo "${1}, $PASSWORD" >>"$PASSWORD_FILE"
}

# Create group function
create_group() {
  groupadd "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log "Error while creating group ${USER}" >&2
  else
    log "Group ${USER} was created successfully."
  fi
}

# Create user function
create_user() {
  useradd -m -g "$1" "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log "Error while creating user ${USER}" >&2
  else
    log "User ${USER} was created successfully."
  fi
}

# Main loop

# Only root can run this script
check_root

if [[ $# -eq 0 ]]; then
  usage
fi

# Parse arguments with getopts
while getopts hp:P:svl OPTION; do
  case $OPTION in
  h)
    usage
    ;;
  p)
    PASSWORD_FILE="${OPTARG}"
    ;;
  P)
    LENGTH="${OPTARG}"
    ;;
  s)
    SPECIAL='true'
    ;;
  v)
    VERBOSE=1
    ;;
  l)
    LOG=1
    ;;
  ?)
    usage
    ;;
  esac
done

shift "$((OPTIND - 1))"

if [[ ${#} -eq 0 ]]; then
  usage
fi

while [[ ${#} -gt 0 ]]; do
  USERS+=("$1")
  shift
done

for USER in "${USERS[@]}"; do
  # Create new group
  if [[ $(cat /etc/group | grep -cw "${USER}") -gt 0 ]]; then
    log "Group ${USER} already exists." >&2
  else
    create_group "$USER"
  fi

  # Create new user
  if [[ $(cat /etc/passwd | grep -cw "${USER}") -gt 0 ]]; then
    log "User ${USER} already exists." >&2
  else
    create_user "$USER"
    generate_password "$USER"
  fi
done
