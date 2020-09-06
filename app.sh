# to run
# ssh root@_secret_ip_
# curl -O -L https://raw.githubusercontent.com/token-cjg/hello_nodejs/master/app.sh

# get the app
git clone https://github.com/token-cjg/coronavirus-simulation.git
cd coronavirus-simulation
sudo npm install
pm2 stop npm
pm2 start npm -- start
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u cgoddard --hp /home/cgoddard

# check nginx
sudo nginx -t
sudo systemctl restart nginx
