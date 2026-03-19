#/bin/bash

# default backup directory
DESTINATION='/tmp'

log() {
  echo $1 
  logger -t $0 $1
}

backup_file() {
  # function to backup file or directory into $DESTINATION directory
  local SOURCE=$1
  local DEST=${DESTINATION}/$(basename $SOURCE)-$(date +%F-%N)

  # backup file
  if [[ -f "$SOURCE" ]]
  then
    cp -p $SOURCE $DEST &>/dev/null
    if [[ $? -eq 0 ]]
    then
      log "Backup of file $SOURCE into folder $(dirname $DEST) was successfull!"
      return 0
    else
      log "Backup of file $SOURCE into folder $(dirname $DEST) failed!" 
    fi
  
  # backup directory
  elif [[ -d "$SOURCE" ]]
  then
    cp -pr $SOURCE $DEST &>/dev/null
    if [[ $? -eq 0 ]]
    then
      log "Backup of directory $SOURCE into folder $(dirname $DEST) was successfull!"
      return 0
    else
      log "Backup of directory $SOURCE into folder $(dirname $DEST) failed!"
    fi
 
  # operation not successfull
  else
    log "File or directory $SOURCE does not exist!" >&2
    return 1
  fi
}

# test if argument was provided
if [[ $# -eq 0 ]]
then
  echo "Usage: $0 [-d DESTINATION] FILE|DIRECTORY [FLE|DIRECTORY]..." >&2
  exit 1
fi

# main 
while [[ $# -gt 0 ]]
do
  case $1 in 
   -d | --destination)
     shift
     DESTINATION="$1"
     mkdir -p $DESTINATION &>/dev/null
     if [[ $? -eq 0 ]] 
     then
       log "Created new directory $DESTINATION"
     else
       log "Error while creating directory $DESTINATION" >&2
       exit 1
     fi
     shift
     ;;
   *)
     backup_file $1
     shift
     ;;
  esac
done
