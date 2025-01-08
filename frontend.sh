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

## Check Nginx already installed or not
dnf list installed nginx    &>>$LOG_FILE_NAME
if [ "$?" -eq "0" ]
then
    echo -e " $GREEN Nodejs $NOCOLOR module is aleady ...$BLUE Installed $NOCOLOR "    
fi

## Install Nginx
dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATION "$?" " Installing Nginx "

## Enable nginx
systemctl enable --now nginx   &>>$LOG_FILE_NAME
VALIDATION "$?" " Enabling & Staring Nginx "

## Remove the default content that web server is serving.
rm -rf /usr/share/nginx/html/*

## Download the frontend content
rm -rf /tmp/frontend.zip ## Making sure to remove the zip file if already exists
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOG_FILE_NAME

## Extract the frontend content.
cd /usr/share/nginx/html  ## going in to the nginix html code path
unzip /tmp/frontend.zip &>>$LOG_FILE_NAME  
VALIDATION "$?" "Unzippinng Frontend code Zip file"

## Loading the reversee proxy config file
cp /home/ec2-user/Expense-Shell/expense.conf  /etc/nginx/default.d/expense.conf

## Restart Nginx Service to load the changes of the configuration.
systemctl restart nginx &>>$LOG_FILE_NAME  
VALIDATION "$?" "Server started"




