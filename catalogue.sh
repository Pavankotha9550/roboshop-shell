source ./common.sh

dnf module disable nodejs -y &>>$log_file
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"


check_user &>>$log_file

mkdir -p /app 
VALIDATE $? "making app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downlading zip is success"

rm -rf /app/*
cd /app 
VALIDATE $? "moving to app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "unziping catalogue zip in app"


npm install &>>$log_file
VALIDATE $? "installing npm dependendies"

cp $script_dir/catalogue.services /etc/systemd/system/catalogue.service
sed -i 's/<MONGODB-SERVER-IPADDRESS>/mongodb.daws84.cyou/' /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue. services is done"

systemctl daemon-reload
VALIDATE $? "reloading of services"

systemctl enable catalogue 
VALIDATE $? "enabiling catalogue"

systemctl start catalogue &>>$log_file
VALIDATE $? "start catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$log_file
VALIDATE $? "installing mongodb client"

status=$(mongosh --host mongodb.daws84.cyou --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $status -eq 0 ]
    then 
        mongosh --host mongodb.daws84.cyou </app/db/master-data.js &>>$log_file
        VALIDATE $? "loading masterdata to db"
    else 
        echo -e "$y data already exist $w"
fi

