#!/bin/bash

# to run
# ssh root@_secret_ip_
# curl -O -L https://raw.githubusercontent.com/token-cjg/hello_nodejs/master/prereqs.sh

# purge first!
sudo apt-get purge -y nginx nginx-common

# nginx
sudo apt-get install -y nginx
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable
sudo ufw status
sudo systemctl status nginx

# nginx, use our defined default file instead
sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-available
curl -O -L https://raw.githubusercontent.com/token-cjg/hello_nodejs/master/fixtures/nginx-default
sudo mv nginx-default /etc/nginx/sites-enabled/default

# # nginx, HTTPS /w lets encrypt
# # note, need a domain - get one from freenom
# sudo add-apt-repository ppa:certbot/certbot -y
# sudo apt-get update -y
# sudo apt-get install python-certbot-nginx -y
# sudo nginx -t
# sudo systemctl reload nginx
# sudo certbot --nginx -d groklemins.tk --keep-until-expiring --no-redirect --register-unsafely-without-email --agree-tos
# # sudo certbot renew --dry-run

# nodejs
cd ~
curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

# install PM2
sudo npm install -g pm2

# # clone helloworld nodejs and run in background
# curl -O -L https://raw.githubusercontent.com/token-cjg/hello_nodejs/master/fixtures/hello.js
# sudo chmod +x ./hello.js
# pm2 start hello.js
# sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u cgoddard --hp /home/cgoddard
# systemctl status pm2-cgoddard

# check nginx
sudo nginx -t
sudo systemctl restart nginx
