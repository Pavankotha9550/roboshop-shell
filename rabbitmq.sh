source ./common.sh

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$log_file
VALIDATE $? "installing rabbitmq server is $G success $W"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "start and enabiling rabbitmq is $G success $W"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "adding roboshop user and password is $G success $W"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting permissions to roboshop user is $G Success $W"
