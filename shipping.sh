source ./common.sh

dnf install maven -y &>>$log_file
VALIDATE $? "installing maven is $G success $W"

check_user

mkdir -p /app
VALIDATE $? "validating $Y app is done $W"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "downlading zip is success"

rm -rf /app/*
cd /app 
VALIDATE $? "moving to app directory"

unzip /tmp/shipping.zip
VALIDATE $? "unziping catalogue zip in app"

cd /app 
mvn clean package &>>$log_file
VALIDATE $? "installing npm dependendies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving the file is $G success $W"

cp $script_dir/shipping.service /etc/systemd/system/shipping.service
sed -i 's/<CART-SERVER-IPADDRESS>/cart.daws84.cyou/' /etc/systemd/system/shipping.service
sed -i 's/<MYSQL-SERVER-IPADDRESS>/mysql.daws84.cyou/' /etc/systemd/system/shipping.service
VALIDATE $? "copying shipping. services is done"

systemctl daemon-reload
VALIDATE $? "reloading of demon is success"

systemctl enable shipping 
systemctl start shipping
VALIDATE $? "enabiling ans start of shipping is done"

dnf install mysql -y &>>$log_file
VALIDATE $? "installing mysql client"

mysql -h mysql.daws84.cyou -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "loading the schema is $Y success $W"

mysql -h mysql.daws84.cyou -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "creating the app user is $Y success $W"

mysql -h mysql.daws84.cyou -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "loading the master date is auccess"

systemctl restart shipping
VALIDATE $? "restarting the shipping is $Y Success $W"
