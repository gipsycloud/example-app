output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP address of the ec2 instance"
}

output "hello_endpoint" {
  value       = "http://${aws_instance.web.public_ip}/api/v1/hello"
  description = "The hello endpoint of the express.js application"
}