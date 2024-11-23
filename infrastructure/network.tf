data "aws_vpc" "default" {
  default = true
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

resource "aws_security_group" "backend" {
  name        = "http 3000 only backend"
  description = "Allow http traffic on port 3000 from anywhere in the world"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    "lab" = "example"
  }
}

resource "aws_security_group" "frontend" {
  name        = "http 80 only frontend"
  description = "Allow http traffic on port 80 from anywhere in the world"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    "lab" = "example"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_3000" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 3000
  to_port     = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_backend_all" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_frontend_all" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = -1
}