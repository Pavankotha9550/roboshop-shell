source ./common.sh

dnf install python3 gcc python3-devel -y &>>$log_file
VALIDATE $? "installing python is $G success $W"

check_user

mkdir -p /app
VALIDATE $? "making app directory is $G success $W"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "downloading code is $G success $W"

cd /app
rm -rf ?app/* 
VALIDATE $? "moving to app directory is $G Success $W"

unzip /tmp/payment.zip
VALIDATE $? "unzipping payment is $G success $W"

cd /app 
pip3 install -r requirements.txt &>>$log_file
VALIDATE $? "installing requirement is $G success $W"

cp $script_dir/payment.service /etc/systemd/system/payment.service
sed -i 's/<CART-SERVER-IPADDRESS>/cart.daws84.cyou/' /etc/systemd/system/payment.service
VALIDATE $? "changing cart ip is $Y success $W"
sed -i 's/<USER-SERVER-IPADDRESS>/user.daws84.cyou/' /etc/systemd/system/payment.service
VALIDATE $? " $Y changing user ip is success $W"
sed -i 's/<RABBITMQ-SERVER-IPADDRESS>/rabbitmq.daws84.cyou/' /etc/systemd/system/payment.service
VALIDATE $? " $Y rabbitmq ip changing is success $W"

systemctl daemon-reload
VALIDATE $? "reloading of service file is success"

systemctl enable payment 
systemctl start payment
VALIDATE $? "$Y enabiling and  start of payment is success "