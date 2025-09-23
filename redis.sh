#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
W="\e[0m"

echo -e "script started executed at $y$(date)$W"

log_folder="/var/log/roboshop-shell"
mkdir -p $log_folder
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log
touch $log_file
script_dir=$PWD

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

dnf module disable redis -y &>>$log_file
dnf module enable redis:7 -y &>>$log_file
VALIDATE $? "disabiling and enabiling redis"

dnf install redis -y  &>>$log_file
VALIDATE $? "insatlling redis"

cd /etc/redis/
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "changing ip"
sed -i 's/protected-mode yes/protected-mode no' /etc/redis/redis.conf
VALIDATE $? "changing protection mode"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "enabiling and starting redis"

