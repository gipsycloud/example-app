data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ssh" {
  name        = "SSH only"
  description = "Allow ssh on port 22 from anywhere in the world"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    "lab" = "example"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server" {
  name        = "http 3000/3001 only server"
  description = "Allow http traffic on port 3000/3001 from the load balancer"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    "lab" = "example"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_server_3000" {
  security_group_id            = aws_security_group.server.id
  referenced_security_group_id = aws_security_group.lb.id

  ip_protocol = "tcp"
  from_port   = 3000
  to_port     = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_server_3001" {
  security_group_id            = aws_security_group.server.id
  referenced_security_group_id = aws_security_group.lb.id

  ip_protocol = "tcp"
  from_port   = 3001
  to_port     = 3001
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_server_all" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = -1
}