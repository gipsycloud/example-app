data "aws_ami" "this" { // virtual machine template
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

resource "aws_launch_template" "backend" {
  name = "expressjs-backend"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  image_id = data.aws_ami.this.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.backend.id,
    aws_security_group.ssh.id,
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ExpressJS Backend"
    }
  }

  user_data = filebase64("${path.module}/configs/backend.sh")
}

resource "aws_autoscaling_group" "backend" {
  name                      = "backend"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 0
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true

  vpc_zone_identifier = data.aws_subnets.public.ids

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 200
  }

  launch_template {
    id      = aws_launch_template.backend.id
    version = aws_launch_template.backend.latest_version
  }

  target_group_arns = [aws_lb_target_group.backend.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      max_healthy_percentage = 200
      min_healthy_percentage = 100
    }
  }
}

# resource "aws_instance" "frontend" { // virtual machine
#   ami           = data.aws_ami.this.id
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ReactJS frontend"
#   }

#   vpc_security_group_ids = [
#     aws_security_group.frontend.id,
#     aws_security_group.ssh.id,
#   ]

#   user_data_base64 = filebase64("${path.module}/configs/frontend.sh")

#   # user_data = <<-EOF
#   #   #!/bin/bash

#   #   # swap file creation
#   #   fallocate -l 4G /swapfile
#   #   chmod 600 /swapfile
#   #   mkswap /swapfile
#   #   swapon /swapfile
#   #   swapon --show
#   #   free -h
#   #   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

#   #   # system update
#   #   sudo dnf update -y
#   #   sudo dnf install -y git
#   #   sudo dnf install -y dnf-plugins-core

#   #   # installing node and npm
#   #   sudo dnf module enable nodejs:18 -y
#   #   sudo dnf install -y nodejs

#   #   node -v
#   #   npm -v

#   #   # installing yarn
#   #   sudo npm install -g yarn

#   #   # cloning Git repository
#   #   cd /home/ec2-user
#   #   git clone https://github.com/hasAnybodySeenHarry/example-app.git
#   #   sudo chown -R $(whoami):$(whoami) /home/ec2-user/example-app
#   #   cd example-app/react-frontend

#   #   # express server ip substitution
#   #   sed -i "s/^REACT_APP_SERVER_IP=.*$/REACT_APP_SERVER_IP=${aws_instance.backend.public_ip}/" .env

#   #   # installing dep
#   #   NODE_OPTIONS="--max-old-space-size=4096" sudo yarn install --production

#   #   # starting the server
#   #   nohup sudo yarn start &
#   # EOF
# }