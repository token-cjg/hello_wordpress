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

# set mysql root password to root
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"

# set up wordpress
mysql -uroot -proot -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -uroot -proot -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'wordpressuserpassword';"
mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# install additional php extensions
sudo apt-get install -y php-curl php-gd php-mbstring php-xml php-xmlrpc
sudo systemctl restart apache2
sudo su
cat <<EOT >> /etc/apache2/apache2.conf
<Directory /var/www/html/>
    AllowOverride All
</Directory>
EOT
exit
sudo a2enmod rewrite
sudo systemctl restart apache2

# download wordpress
sudo mkdir tmp
cd tmp
curl -O https://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz
sudo touch /home/cgoddard/tmp/wordpress/.htaccess
sudo chmod 660 /home/cgoddard/tmp/wordpress/.htaccess
sudo cp /home/cgoddard/tmp/wordpress/wp-config-sample.php /home/cgoddard/tmp/wordpress/wp-config.php
sudo mkdir /home/cgoddard/tmp/wordpress/wp-content/upgrade
sudo cp -a /home/cgoddard/tmp/wordpress/. /var/www/html

# configure wordpress directory

# We’ll start by assigning ownership over all of the files in our
# document root to our username. We will use sammy as our username
# in this guide, but you should change this to match whatever your
# sudo user is called. We will assign group ownership to the
# www-data group:
sudo chown -R cgoddard:www-data /var/www/html

# Next, we will set the setgid bit on each of the directories
# within the document root. This causes new files created within
# these directories to inherit the group of the parent directory
# (which we just set to www-data) instead of the creating user’s
# primary group. This just makes sure that whenever we create a
# file in the directory on the command line, the web server will
# still have group ownership over it.
sudo find /var/www/html -type d -exec chmod g+s {} \;

# There are a few other fine-grained permissions we’ll adjust.
# First, we’ll give group write access to the wp-content directory
# so that the web interface can make theme and plugin changes:
sudo chmod g+w /var/www/html/wp-content

# As part of this process, we will give the web server write
# access to all of the content in these two directories:
sudo chmod -R g+w /var/www/html/wp-content/themes
sudo chmod -R g+w /var/www/html/wp-content/plugins

# set up the wordpress configuration file
sudo apt-get install -y php-cli

sudo su
WPSalts=$(wget https://api.wordpress.org/secret-key/1.1/salt/ -q -O -)
TablePrefx=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)_
WWUSER=$(stat -c '%U' ./)

cat <<EOF > /home/cgoddard/tmp/wordpress/wp-config-sample.php
<?php
/***Managed by Kaiten Support - Leonardo Gandini***/

define('DB_NAME', '');
define('DB_USER', '');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

/*WP Tweaks*/
#define( 'WP_SITEURL', '' );
#define( 'WP_HOME', '' );
#define( 'ALTERNATE_WP_CRON', true );
#define('DISABLE_WP_CRON', 'true');
#define('WP_CRON_LOCK_TIMEOUT', 900);
#define('AUTOSAVE_INTERVAL', 300);
#define( 'WP_MEMORY_LIMIT', '256M' );
#define( 'FS_CHMOD_DIR', ( 0755 & ~ umask() ) );
#define( 'FS_CHMOD_FILE', ( 0644 & ~ umask() ) );
#define( 'WP_ALLOW_REPAIR', true );
#define( 'FORCE_SSL_ADMIN', true );
#define( 'AUTOMATIC_UPDATER_DISABLED', true );
#define( 'WP_AUTO_UPDATE_CORE', false );

$WPSalts

\$table_prefix = '$TablePrefx';

define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpressuser');

/** MySQL database password */
define('DB_PASSWORD', 'wordpressuserpassword');

define('FS_METHOD', 'direct');

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF
exit

sudo cp /home/cgoddard/tmp/wordpress/wp-config-sample.php /var/www/html/wp-config.php
