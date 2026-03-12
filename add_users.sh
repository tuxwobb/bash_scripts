#!/bin/bash

USERS=("test" "test2" "test3" "test4" "test5")
LOG_FILE="log.txt"
PASSWORD_FILE="pass.txt"

log_message() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') >>> ${1}" >>$LOG_FILE
}

generate_password() {
  openssl rand -base64 12
}

create_group() {
  groupadd "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log_message "Error while creating group ${USER}"
  else
    log_message "Group ${USER} was created successfully."
  fi
}

create_user() {
  useradd -m -g "$1" "$1" &>/dev/null
  if [[ ! ${?} ]]; then
    log_message "Error while creating user ${USER}"
  else
    log_message "User ${USER} was created successfully."
  fi
}

# Only root can run this script
if [[ $UID -ne 0 ]]; then
  log_message "You must be root!"
  exit 1
fi

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

    PASSWORD=$(generate_password)
    echo "$USER:$PASSWORD" | chpasswd
    # Save user and password to a file
    echo "$USER,$PASSWORD" >>"$PASSWORD_FILE"
  fi

done
