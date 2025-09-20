#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
W="\e[0m"

echo -e "script started executed at $y$(date)$W"

log_folder="var/log/roboshop-shell"
mkdir -p $log_folder
script_name=$(echo $0 | cut -d "." -f1)
log_file=$log_folder/$script_name.log
touch $log_file


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

dnf module disable nodejs -y &>>$log_file
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "adding roboshop user"

mkdir /app 
VALIDATE $? "making app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downlading zip is success"

cd /app 
VALIDATE $? "moving to app directory"

zip /tmp/catalogue.zip
VALIDATE $? "unziping catalogue zip in app"

npm install &>>$log_file
VALIDATE $? "installing npm dependendies"

cd /home/ec2-user/roboshop-shell
sed -i 's/<MONGODB-SERVER-IPADDRESS>/mongodb.daws84.cyou/' catalogue.services
cp catalogue.services /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue. services is done"

systemctl daemon-reload
VALIDATE $? "reloading of services"

systemctl enable catalogue 
VALIDATE $? "enabiling catalogue"

systemctl start catalogue &>>$log_file
VALIDATE $? "start catalogue"

cd /home/ec2-user/roboshop-shell
dnf install mongodb-mongosh -y 
VALIDATE $? "installing mongodb client"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
VALIDATE $? "loading masterdata to db"

