#!/bin/bash

USERS=()
LOG_FILE="log.txt"
PASSWORD_FILE="pass.txt"
VERBOSE=0
HELP="Script to add users into system
-v | --verbose - write log to standard output
-h | --help - help"

# Check root function
check_root() {
  if [[ $UID -ne 0 ]]; then
    echo "You must be root!"
    exit 1
  fi
}

# Log message function
log_message() {
  if [[ $VERBOSE -eq 1 ]]; then
    echo -e "${1}"
  fi
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') >>> ${1}" >>$LOG_FILE
}

# Generate passowrd function
generate_password() {
  openssl rand -base64 12
}

# Store password function
store_password() {
  PASSWORD=$(generate_password)
  echo "$1:$PASSWORD" | chpasswd
  echo "$1,$PASSWORD" >>"$PASSWORD_FILE"
}

# Create group function
create_group() {
  groupadd "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log_message "Error while creating group ${USER}"
  else
    log_message "Group ${USER} was created successfully."
  fi
}

# Create user function
create_user() {
  useradd -m -g "$1" "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log_message "Error while creating user ${USER}"
  else
    log_message "User ${USER} was created successfully."
  fi
}

# Main loop

# Only root can run this script
check_root

# Parse arguments
if [[ $# -eq 0 ]]; then
  echo -e "$HELP"
fi

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    echo -e "$HELP"
    shift
    ;;
  -v | --verbose)
    VERBOSE=1
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
    log_message "Group ${USER} already exists."
  else
    create_group "$USER"
  fi

  # Create new user
  if [[ $(cat /etc/passwd | grep -cw "${USER}") -gt 0 ]]; then
    log_message "User ${USER} already exists."
  else
    create_user "$USER"
    store_password "$USER"
  fi

done
