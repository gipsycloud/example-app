resource "aws_launch_template" "server" {
  name = "app-server"

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

  user_data = filebase64("${path.module}/configs/docker.sh")
}

resource "aws_autoscaling_group" "server" {
  name                      = "server"
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
    id      = aws_launch_template.server.id
    version = aws_launch_template.server.latest_version
  }

  target_group_arns = [
    aws_lb_target_group.backend.arn,
    aws_lb_target_group.frontend.arn,
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      max_healthy_percentage = 200
      min_healthy_percentage = 100
    }
  }
}