data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.this.id
  instance_type = "t2.micro"

  # key_name = aws_key_pair.web_key.key_name

  tags = {
    Name = "Hello, Discord!"
  }

  vpc_security_group_ids = [aws_security_group.http.id]

  user_data = <<-EOF
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

    npm install

    sudo node index.js
  EOF

  provisioner "remote-exec" {
    inline = [
      "sleep 120",
      "cd /home/ec2-user/example-app/react-frontend",
      "sed -i 's/^REACT_APP_SERVER_IP=.*$/REACT_APP_SERVER_IP=${self.public_ip}/' .env",
      "npm install",
      "npm start &"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user" 
      private_key = tls_private_key.web_key.private_key_pem
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "http" {
  name        = "http only"
  description = "Allow http traffic from anywhere in the world"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    "lab" = "example"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.http.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.http.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_3000" {
  security_group_id = aws_security_group.http.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 3000
  to_port     = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.http.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = -1
}