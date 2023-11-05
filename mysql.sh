source common.sh

if [ -z "$1" ]; then
  echo Password input missing
  exit
fi
MYSQL_ROOT_PASSWORD=$1

echo -e "${color} Disable Mysql default version \e[0m"
dnf module disable mysql -y &>>log_file
status_check

echo -e "${color} Copy mysql repo file \e[0m"
cp mysql.repo /etc/yum.repos.d/mysql.repo &>>log_file
status_check

echo -e "${color} Install mysql serverx \e[0m"
dnf install mysql-community-server -y &>>log_file
status_check

echo -e "${color} Start mysql server \e[0m"
systemctl enable mysqld &>>log_file
systemctl start mysqld &>>log_file
status_check

echo -e "${color} Set mysql password \e[0m"
mysql_secure_installation --set-root-pass ${MYSQL_ROOT_PASSWORD} &>>log_file
status_check