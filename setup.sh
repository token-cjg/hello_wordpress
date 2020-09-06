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
curl -O -L https://raw.githubusercontent.com/token-cjg/hello_wordpress/master/mysql_secure.sh
sudo chmod +x mysql_secure.sh
sudo ./mysql_secure.sh 'root'

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
