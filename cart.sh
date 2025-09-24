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
VALIDATE $? "disabiling and enabiling nodejs "

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
    then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "adding user roboshop"
    else
    echo -e "$y user already there $w"
fi


mkdir -p /app
VALIDATE $? "creating app directory" 

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "downloading zip"

cd /app
rm -rf /app/*
VALIDATE $? "removing the file in app directory" 
unzip /tmp/cart.zip
VALIDATE $? "unxipping in tmp directory"

cd /app 
npm install 
VALIDATE $? "installing npm"

cp $script_dir/cart.service /etc/systemd/system/cart.service
sed -i 's/<REDIS-SERVER-IP>/redis.daws84.cyou/' /etc/systemd/system/cart.service
VALIDATE $? "changing redis ip"
sed -i 's/<CATALOGUE-SERVER-IP>/catalogue.daws.cyou/' /etc/systemd/system/cart.service
VALIDATE $? "changing catalogue ip"

systemctl daemon-reload
VALIDATE $? "reloading service files"

systemctl enable cart 
systemctl start cart
VALIDATE $? "enabiling and start of cart"
