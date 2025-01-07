#!/bin/bash


USERID=`id -u`
GREEN='\033[0;32m'
RED='\033[0;31m'
NOCOLOR='\033[0m'
BLUE='\033[0;34m'
LOG_FOLDER="/var/shell-script-logs"
TIME_STAMP=$(date +%d.%m.%y:%H-%M-%S)
SCRIPT_NAME=`echo $0 | awk -F "." '{print $1}'`
LOG_FILE_NAME=$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log

echo "Script Executed at this $TIME_STAMP"  &>>$LOG_FILE_NAME

## Checking Root user or not 

if [ "$USERID" -ne "0" ]   # Verifying User is root or not.
then
    echo -e "  $RED ERROR:: $NOCOLOR  You Must Have Sudo Access to Execute This Script  "
    exit 1
fi