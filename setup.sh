#!/bin/bash

# to run
# ssh root@_secret_ip_
# curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/setup.sh

# purge first!
sudo apt-get purge -y apache2 mysql-server

# apache2
sudo apt-get update
sudo apt-get install -y apache2
sudo ufw allow in "Apache Full"

# mysql
sudo apt-get install -y mysql-server expect
# SECURE_MYSQL=$(expect -c "
# set timeout 10
# spawn mysql_secure_installation
# expect \"Would you like to setup VALIDATE PASSWORD plugin?\"
# send \"n\r\"
# expect \"Please set the password for root here:\"
# send \"root\r\"
# expect \"Re-enter new password\"
# send \"root\r\"
# expect \"Remove anonymous users?\"
# send \"y\r\"
# expect \"Disallow root login remotely?\"
# send \"y\r\"
# expect \"Remove test database and access to it?\"
# send \"y\r\"
# expect \"Reload privilege tables now?\"
# send \"y\r\"
# expect eof
# ")
#
# echo "$SECURE_MYSQL"
# sudo apt-get purge -y expect

# php
sudo apt-get install -y php libapache2-mod-php php-mysql

sudo mv /etc/apache2/mods-enabled/dir.conf /etc/apache2/mods-enabled/dir_orig.conf
curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/fixtures/dir.conf
sudo mv dir.conf /etc/apache2/mods-enabled/dir.conf

sudo systemctl restart apache2

# set up virtual hosts
sudo mkdir /var/www/tweetysoap
sudo chown -R $USER:$USER /var/www/tweetysoap
sudo chmod -R 755 /var/www/tweetysoap
curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/fixtures/index.html
curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/fixtures/tweetysoap.conf
sudo mv index.html /var/www/tweetysoap/index.html
sudo mv tweetysoap.conf /etc/apache2/sites-available/tweetysoap.conf
sudo a2ensite tweetysoap.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# test php
# curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/fixtures/info.php
# sudo mv info.php /var/www/tweetysoap/info.php
# sudo rm /var/www/tweetysoap/info.php

mysql -u root -p -e "SQL_QUERY"
