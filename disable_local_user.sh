#!/bin/bash

ARCHIVE_DESTINATION='/home/wobbler/Backup'

# Usage
usage() {
  echo "Usage: disable-local-user.sh [-h] USERNAME [USERNAME...]"
  echo "  Script will disable provided list of user accounts on local system."
  echo "    -h  show help"
  echo "    -d  permanently delete user account"
  echo "    -r  remove user home directory"
  echo "    -a  create archive of user home directory into /archives directory"
  echo "    -v  verbosity of the output"
  exit 1
}

if [[ $UID -ne 0 ]]; then
  echo "This script must be executed with root privileges." >&2
  exit 1
fi

# Parse options
while getopts hdra OPTION; do
  case $OPTION in
  h)
    usage
    ;;
  d)
    DELETE_USER_ACCOUNT='true'
    ;;
  r)
    REMOVE_HOME_DIRECTORY='-r'
    ;;
  a)
    ARCHIVE_HOME_DIRECTORY='true'
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

# Parse other arguments
for USER in "${@}"; do
  echo "Processing user: ${USER}"

  # Refuse to delete non existing users or users with id < 1000
  if [[ $(id -u "${USER}" 2>/dev/null) -lt 1001 ]]; then
    echo "You delete/disable ${USER}! It does not exist it has id < 1000" >&2

  else
    # Archive home directory
    if [[ ${ARCHIVE_HOME_DIRECTORY} == 'true' ]]; then
      if [[ ! -d ${ARCHIVE_DESTINATION} ]]; then
        mkdir -p ${ARCHIVE_DESTINATION} &>/dev/null
      fi
      if tar -czf "${ARCHIVE_DESTINATION}"/"${USER}"-"$(date +%F-%N)".tar.gz /home/"${USER}" &>/dev/null; then
        echo "Archive of user ${USER} home directory completed!"
      else
        echo "Error while archiving ${USER} home directory!"
      fi
    fi

    # Remove user account
    if [[ ${DELETE_USER_ACCOUNT} == 'true' ]]; then
      if userdel "${REMOVE_HOME_DIRECTORY}" "${USER}" &>/dev/null; then
        echo "User ${USER} was deleted successfully!"
      else
        echo "Error while deleting user ${USER}!"
      fi

    # Disable user account
    else
      if usermod -L -e 1 "${USER}" &>/dev/null; then
        echo "User ${USER} was disabled!"
      else
        echo "Error while disabling ${USER}!"
      fi
    fi
  fi

  shift
done
