source ./common.sh

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

ENDTIME