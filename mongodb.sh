#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
W="\e[0m"

echo -e "script started executed at $y$(date)$W"

log_folder="var/log/shell-scripting-logs"
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log
mkdir -p $log_folder

echo "userid:$userid"
if [ $userid -ne 0 ] 
then
    echo -e "$R error: not sudo user $W" | tee -a $log_file
    exit 1
else
    echo -e "$G running with sudo user $W" | tee -a $log_file
fi


VALIDATE()
{
     if [ $1 -eq 0 ]
    then
        echo -e "$G installation $2 is success $W" | tee -a $log_file
    else
        echo -e "$R error: installation $2 failed $W" | tee -a $log_file
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo db repo"

dnf install mongodb-org -y 
VALIDATE $? "installing mongo db"

systemctl enable mongod 
VALIDATE $? "enabiling mongodb"

systemctl start mongod 
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0' /etc/mongod.conf
VALIDATE $? "editing mongodb configuration"

systemctl restart mongod
VALIDATE $? "restarting mongodb"