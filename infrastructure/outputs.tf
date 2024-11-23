output "frontend_ip" {
  value       = "http://${aws_instance.frontend.public_ip}"
  description = "The public IP address of the frontend instance"
}

output "backend_endpoint" {
  value       = "http://${aws_instance.backend.public_ip}:3000/api/v1/hello"
  description = "The hello endpoint of the express.js application"
}