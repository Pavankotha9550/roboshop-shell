source ./common.sh

dnf module disable redis -y &>>$log_file
dnf module enable redis:7 -y &>>$log_file
VALIDATE $? "disabiling and enabiling redis"

dnf install redis -y  &>>$log_file
VALIDATE $? "insatlling redis"

cd /etc/redis/
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "changing ip"
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "changing protection mode"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "enabiling and starting redis"

