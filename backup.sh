#/bin/bash

readonly BACKUP_LOCATION='/tmp'

backup_file() {
  # function to backup file or directory into global variable BACKUP_LOCATION
  local FILE=$1

  # backup file
  if [[ -f "$FILE" ]]
  then
    cp -p $FILE ${BACKUP_LOCATION}/$(basename $FILE)-$(date +%F-%N)
    if [[ $? -eq 0 ]]
    then
      echo "Backup of file $FILE was successfull!"
      return 0
    fi
  
  # backup directory
  elif [[ -d "$FILE" ]]
  then
    cp -pr $FILE ${BACKUP_LOCATION}/$(basename $FILE)-$(date +%F-%N)
    if [[ $? -eq 0 ]]
    then
      echo "Backup of directory $FILE was successfull!"
      return 0
    fi
 
  # operation not successfull
  else
    echo "File or directory $FILE does not exist!" >&2
    return 1
  fi
}

# test if argument was provided
if [[ $# -eq 0 ]]
then
  echo "Usage: $0 FILENAME|DIRNAME [FILENAME|DIRNAME]..." >&2
  exit 1
fi

# main 
for input in "$@"
do
  backup_file $1
  shift
done

