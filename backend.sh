source common.sh

if [ -z "$1" ]; then
  echo Password input missing
  exit
fi
MYSQL_ROOT_PASSWORD=$1


echo -e "${color} Disable NodeJs default version \e[0m"
dnf module disable nodejs -y &>>log_file
status_check

echo -e "${color} Enable NodeJs 18 version \e[0m"
dnf module enable nodejs:18 -y &>>log_file
status_check

echo -e "${color} Installing NodeJs \e[0m"
dnf install nodejs -y &>>log_file
status_check

echo -e "${color} Copy backend service file \e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>>log_file
status_check


id expense &>>log_file
if [ $? -ne 0 ]; then
  echo -e "${color} Add application user \e[0m"
  useradd expense &>>log_file
  status_check
fi

if [ ! -d /app ]; then
  echo -e "${color} Create application directory \e[0m"
  mkdir /app &>>log_file
  status_check
fi

echo -e "${color} Delete old application content \e[0m"
rm -rf /app/* &>>log_file
status_check

echo -e "${color} Download application content \e[0m"
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/backend.zip &>>log_file
status_check

echo -e "${color} Extract application content \e[0m"
cd /app
unzip /tmp/backend.zip &>>log_file
status_check

echo -e "${color} Download NodeJs dependencies \e[0m"
cd /app
npm install &>>log_file
status_check

echo -e "${color} Install Mysql client to load schema \e[0m"
dnf install mysql -y &>>log_file
status_check

echo -e "${color} Load schema \e[0m"
mysql -h mysql-dev.devopspv24.online -uroot -p${MYSQL_ROOT_PASSWORD} < /app/schema/backend.sql &>>log_file
status_check

echo -e "${color} Starting backend service \e[0m"
systemctl daemon-reload &>>log_file
systemctl enable backend &>>log_file
systemctl restart backend &>>log_file
status_check
