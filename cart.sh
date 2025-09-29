source ./common.sh

dnf module disable nodejs -y &>>$log_file
dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "disabiling and enabiling nodejs "

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"

check_user 


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
npm install &>>$log_file
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
