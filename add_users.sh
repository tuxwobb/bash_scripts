#!/bin/bash

USERS=()
PASSWORD_FILE="pass.txt"
LENGTH=30
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
  echo "  -h | --help    man page"
  echo "  -p FILE        password file"
  echo "  -P LENGTH      password lentgh (default 30)"
  echo "  -s | --special add special character into password"
  echo "  -v | --verbose write log to standard output"
  echo "  -l | --log     write log to syslog"
  echo
  exit 1
}

# Log message function
log() {
  MESSAGE="$@"
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "$MESSAGE"
  fi
  if [[ $LOG -eq 1 ]]; then
    logger -t $0 "${MESSAGE}"
  fi
}

# Generate password
generate_password() {
  PASSWORD=$(date +%F%N${RANDOM}${RANDOM} | sha256sum | head -c${LENGTH})
  if [[ $SPECIAL -eq 'true' ]]; then
    PASSWORD=${PASSWORD}$(echo $SPECIAL_CHARS | fold -w1 | shuf | head -c1)
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

# Parse arguments
if [[ $# -eq 0 ]]; then
  usage 
fi

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 1
    ;;
  -p)
    shift
    PASSWORD_FILE="$1"
    shift
    ;;
  -P)
    shift
    LENGTH="$1"
    shift
    ;;
  -s | --special)
    SPECIAL='true'
    shift
    ;;
  -v | --verbose)
    VERBOSE=1
    shift
    ;;
  -l | --log)
    LOG=1
    shift
    ;;
  *)
    USERS+=("$1")
    shift
    ;;
  esac
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
