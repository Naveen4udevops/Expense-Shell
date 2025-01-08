#!/bin/bash


USERID=`id -u`
GREEN='\033[0;32m'
RED='\033[0;31m'
NOCOLOR='\033[0m'
BLUE='\033[0;34m'
mkdir -p /var/shell-script-logs
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


## Validation function

VALIDATION(){

if [ "$1" -eq "0" ] # Validating previous command success or not.
then
    echo -e  " "$2"...$GREEN SUCCESS $NOCOLOR "    #Informing to user.
else
    echo  -e " "$2"....$RED FAILED $NOCOLOR"       #Informing to user.
    exit 1
fi
}
 
## Check nodejs already installed or not
dnf list installed nodejs   &>>$LOG_FILE_NAME
if [ "$?" -eq "0" ]
then
    echo -e " $GREEN Nodejs $NOCOLOR module is aleady ...$BLUE Installed $NOCOLOR "    
fi

#   Disabling default nodejs.module
    dnf module disable nodejs -y   &>>$LOG_FILE_NAME
    VALIDATION "$?" " Disabled Default Nodejs Module "

#   Enabling nodejs module
    dnf module enable nodejs:20 -y   &>>$LOG_FILE_NAME
    VALIDATION "$?" " Enabled latest Nodejs Module "

#   Installing nodejs module
    dnf install nodejs -y   &>>$LOG_FILE_NAME
    VALIDATION "$?" " Installed Nodejs Module "

#   adding normal user to start backend service with limited privilages
    useradd expense &>>$LOG_FILE_NAME
    VALIDATION "$?" " User Added "

#   Setup an app directory to keep the Nodejs code"
    mkdir -p /app &>>$LOG_FILE_NAME

#   Download the application code to created app directory.
    rm -rf /tmp/backend.zip  # Before downloading removig if any existing backend zip file
    curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip 
    VALIDATION "$?" " Downloaded Backend-code "
 
#   Go to the app directory 
    cd /app   &>>$LOG_FILE_NAME

#  Unzip the code to the app directory
   rm -rf /app/* &>>$LOG_FILE_NAME
   unzip /tmp/backend.zip  &>>$LOG_FILE_NAME
   VALIDATION "$?" " Unzip Downloaded Backend-code "

#  Lets download the dependencies.
   npm install &>>$LOG_FILE_NAME
   VALIDATION "$?" " Dependencies Installed "

#  Setup SystemD Expense Backend Service to run backend code as a Service
   cp Backend.service /etc/systemd/system/backend.service

#  Load the services, Since new sevice has added in SystemD.
   systemctl daemon-reload

# Enable & Start the backend Service to starte Connection between "Backend-Server & Mysql-server"
  systemctl enable backend
  VALIDATION "$?" "Enabled & started the Backend Service"

# load Expense data base schema to the Database, Which came along with the Backend code. 
  # To do that First we need to Install mySql client here, to connect to MYsql-server

   dnf install mysql -y
   VALIDATION "$?" "Installed MySQl-Client"

   mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
   VALIDATION "$?" "Loading Database Schema to Mysql-Server"

# Restart the service once after loading Database Schema to Mysql-server
   systemctl restart backend

fi
