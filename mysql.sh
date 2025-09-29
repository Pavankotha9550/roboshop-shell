./ common.sh

dnf install mysql-server -y
VALIDATE $? "installing mysql server is success"

systemctl enable mysqld
systemctl start mysqld  
VALIDATE $? "enabiling and disabling mysql server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting up password is $G success $W"