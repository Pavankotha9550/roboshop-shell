source ./common.sh

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo db repo"

dnf install mongodb-org -y &>>$log_file
VALIDATE $? "installing mongo db"

systemctl enable mongod 
VALIDATE $? "enabiling mongodb"

systemctl start mongod 
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "editing mongodb configuration"

systemctl restart mongod 
VALIDATE $? "restarting mongodb"