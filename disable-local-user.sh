#!/bin/bash

ARCHIVE_DESTINATION="/home/wobbler/Backup"
VERBOSE="false"

usage() {
  echo "Usage: disable-local-user.sh [-h] USERNAME [USERNAME...]"
  echo "  Script will disable provided list of user accounts on local system."
  echo "    -h  show help"
  echo "    -d  permanently delete user account"
  echo "    -r  remove user home directory"
  echo "    -a  create archive of user home directory into /archives directory"
  echo "    -v  verbosity of the output"
  echo
  exit 1
}

log() {
  MESSAGE="${*}"
  if [[ $VERBOSE == "true" ]]; then
    echo "$MESSAGE"
  fi
}

while getopts hdrav OPTION; do
  case $OPTION in
  h)
    usage
    ;;
  d)
    DELETE_USER_ACCOUNT='true'
    ;;
  r)
    REMOVE_HOME_DIRECTORY='true'
    ;;
  a)
    ARCHIVE_HOME_DIRECTORY='true'
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

if [[ ${#} -eq 0 ]]; then
  usage
fi

if [[ $UID -ne 0 ]]; then
  echo "This script must be executed with root privileges." >&2
  exit 1
fi

while [[ ${#} -gt 0 ]]; do

  # check if user account exists
  USER_ID=$(id -u "$1" 2>/dev/null)
  USER_NAME=$1

  if [[ $? -gt 0 ]]; then
    echo "User $USER_NAME doesn´t exist!"
  elif [[ $USER_ID -eq "" ]]; then
    echo "User $USER_NAME can´t be deleted, because it doesn´t exists."
  else
    if [[ $USER_ID -lt 1001 ]]; then
      echo "You can´t disable/delete user with id < 1000 (${USER_NAME})!" >&2

    else
      if [[ $ARCHIVE_HOME_DIRECTORY == 'true' && -d /home/$USER_NAME ]]; then
        # archive user home directory if exist
        log "Archiving user $USER_NAME home directory..."
        mkdir -p $ARCHIVE_DESTINATION &>/dev/null
        tar -cvf ${ARCHIVE_DESTINATION}/${USER_NAME}-$(date +%F-%N).tar /home/${USER_NAME} &>/dev/null
        echo "Archiving of user $USER_NAME home directory completed!"
      fi

      if [[ $DELETE_USER_ACCOUNT == 'true' ]]; then
        # remove user
        if [[ $REMOVE_HOME_DIRECTORY == 'true' ]]; then
          log "Deleting user account with home directory ${USER_NAME}..."
          userdel -r "$USER_NAME" &>/dev/null
          echo "User $USER_NAME and his home directory was deleted successfully!"
        else
          log "Deleting user account ${USER_NAME}..."
          userdel "$USER_NAME" &>/dev/null
          echo "User $USER_NAME was deleted successfully!"
        fi

      else
        # locking user acount only
        log "Locking user account ${USER_NAME}..."
        usermod -L -e 1 "${USER_NAME}" &>/dev/null
        echo "User $USER_NAME was locked successfully!"
      fi
    fi
  fi

  shift
done
