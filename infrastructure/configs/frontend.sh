#!/bin/bash

# swap file creation
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
free -h
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# system update
sudo dnf update -y
sudo dnf install -y git
sudo dnf install -y dnf-plugins-core

# installing node and npm
sudo dnf module enable nodejs:18 -y
sudo dnf install -y nodejs

node -v
npm -v

# installing yarn
sudo npm install -g yarn

# cloning Git repository
cd /home/ec2-user
git clone https://github.com/hasAnybodySeenHarry/example-app.git
sudo chown -R $(whoami):$(whoami) /home/ec2-user/example-app
cd example-app/react-frontend

# express server ip substitution
sed -i "s/^REACT_APP_SERVER_IP=.*$/REACT_APP_SERVER_IP=${aws_instance.backend.public_ip}/" .env

# installing dep
NODE_OPTIONS="--max-old-space-size=4096" sudo yarn install --production

# starting the server
nohup sudo yarn start &