#!/bin/bash
sudo dnf update -y
sudo dnf install -y git
sudo dnf install -y dnf-plugins-core

sudo dnf module enable nodejs:18 -y
sudo dnf install -y nodejs

node -v
npm -v

cd /home/ec2-user
git clone https://github.com/hasAnybodySeenHarry/example-app.git

cd example-app/express-backend

sudo npm install --verbose && node index.js