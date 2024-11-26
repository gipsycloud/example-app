resource "aws_launch_template" "frontend" {
  name = "reactjs-frontend"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  image_id = data.aws_ami.this.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.frontend.id,
    aws_security_group.ssh.id,
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ReactJS Frontend"
    }
  }

  user_data = base64encode(templatefile("${path.module}/configs/frontend.sh.tmpl", {
    load_balancer_dns = aws_lb.lb.dns_name
  }))
}

resource "aws_autoscaling_group" "frontend" {
  name                      = "frontend"
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
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }

  target_group_arns = [aws_lb_target_group.frontend.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      max_healthy_percentage = 200
      min_healthy_percentage = 100
    }
  }
}