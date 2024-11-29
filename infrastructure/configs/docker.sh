sudo dnf update -y
sudo dnf install -y docker

sudo systemctl enable --now docker

sudo docker --version

sudo docker run -d --name backend -p 3000:3000 {{IMAGE_ID}}