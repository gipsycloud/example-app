resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "hello-discord-key"
  public_key = tls_private_key.web_key.public_key_openssh
}