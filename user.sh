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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
VALIDATE $? "disabiling and enabiling nodejs"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
    then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "adding roboshop user"
    else
    echo -e "$y user already exist $w"
fi

mkdir /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "downloading user files"

rm -rf /app/*
cd /app 
VALIDATE $? "moving to app directory"

unzip /tmp/user.zip
VALIDATE $? "unzipping user files"

npm install 
VALIDATE $? "installing npm dependendies"

cp $script_dir/user.service /etc/systemd/system/user.service
sed -i 's/<REDIS-IP-ADDRESS>/redis.daws84.cyou/'  /etc/systemd/system/user.service
VALIDATE $? "changing ip of redis"
sed -i 's/<MONGODB-SERVER-IP-ADDRESS>/mongodb.daws84.cyou/' /etc/systemd/system/user.service
VALIDATE $? "changing ip of mongo"

systemctl daemon-reload
VALIDATE $? "reloading user.service"

systemctl enable user 
VALIDATE $? "enabiling  user"
systemctl start user
VALIDATE $? "starting user"