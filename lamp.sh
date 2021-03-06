#!/usr/bin/env bash

#User input
IP_ADDRESS="IPADDRESS"
HOST_NAME="HOSTNAME"
DB_PASSWORD="DBPASSWORD"
DB_NAME="DBNAME"
LARAVEL="LARACHECK"

echo "Installing base components"
sudo apt-get install -y vim curl git-core python-software-properties software-properties-common
sudo apt-get install -y git

echo "Initial update"
sudo apt-get update

echo "Installing and configuring Apache Server."
sudo apt-get install -y apache2

#Enable mod rewrite in Apache
sudo a2enmod rewrite
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

if [[ $LARAVEL == "no" ]]
	then
		echo "Setting document root"
		rm -rf /var/www
		mkdir /vagrant/DocRoot
		ln -fs /vagrant/DocRoot /var/www

cat << EOF | sudo tee -a /etc/apache2/apache2.conf
<VirtualHost *:80>
     DocumentRoot /var/www
     ServerName $HOST_NAME
     <Directory "/var/www">
          AllowOverride All
     </Directory>
</VirtualHost>
EOF
fi

sudo service apache2 restart

echo "Installing and configuring MySQL."
export DEBIAN_FRONTEND=noninteractive

#Set passwords for MySQL installation prompt
echo "mysql-server mysql-server/root_password password ${DB_PASSWORD}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DB_PASSWORD}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DB_PASSWORD}" | debconf-set-selections

sudo apt-get install -q -y mysql-server mysql-client
sudo apt-get install -q -y libaio1

sudo apt-get update
sudo service mysql restart

mysql -uroot -e "CREATE DATABASE ${DB_NAME}" -p$DB_PASSWORD

#READ: This is a temporary fix for problems with mysql connections while using a vhost setup
sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'$IP_ADDRESS' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"| mysql -uroot -p$DB_PASSWORD
echo "FLUSH PRIVILEGES"| mysql -uroot -p$DB_PASSWORD
sudo service mysql restart

echo "Installing PHP."
sudo apt-get install -y php5

sudo apt-get update

#Adds debdot sources needed to install php5.5. Install php5.5 manually.
cat << EOF | sudo tee -a /etc/apt/sources.list

#debdot resources 

deb http://packages.dotdeb.org wheezy-php55 all
deb-src http://packages.dotdeb.org wheezy-php55 all

EOF

sudo wget http://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg

sudo apt-get update


echo "Installing and configuring additional components."
sudo apt-get install -y libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql openssl phpunit memcached

#Turn on error reporting
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo "Installing and configuring XDebug."
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "Installing and configuring PHPMyAdmin"

#Set passwords for PHPMyAdmin installation prompt
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DB_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${DB_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install -q -y phpmyadmin

#Add PHPMyAdmin to Apache httpd file
cat << EOF | sudo tee -a /etc/apache2/apache2.conf
Include /etc/phpmyadmin/apache.conf
EOF

echo "Installing Composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#Install NodeJS for Gulp and Bower (Commented out for the time being. Not using these enough yet.)
#echo "Installing Node.JS"
#echo "deb http://ftp.us.debian.org/debian wheezy-backports main" | sudo tee -a /etc/apt/sources.list
#sudo apt-get update
#sudo apt-get install -y nodejs-legacy -q
#curl https://www.npmjs.org/install.sh | sudo clean=no sh
#
#sudo apt-get update
#
#sudo npm install -g bower
#sudo npm install -g gulp
