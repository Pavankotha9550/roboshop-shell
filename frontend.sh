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

dnf module disable nginx -y &>>$log_file
dnf module enable nginx:1.24 -y &>>$log_file
dnf install nginx -y &>>$log_file
VALIDATE $? "disabiling,enabiling,installing nginx"

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "enabiling and starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading the frontend"

cd /usr/share/nginx/html 
VALIDATE $? "going to html content"
unzip /tmp/frontend.zip
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "removing nginx.conf content"
cp $script_dir/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying the content of nginx.conf"

systemctl restart nginx 
VALIDATE $? "restarting nginx"
