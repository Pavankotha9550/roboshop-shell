source ./common.sh

dnf module disable nodejs -y &>>$log_file
dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "disabiling and enabiling nodejs" 

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"

check_user &>>$log_file

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "downloading user files"

rm -rf /app/*
cd /app 
VALIDATE $? "moving to app directory"

unzip /tmp/user.zip
VALIDATE $? "unzipping user files"

npm install &>>$log_file
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