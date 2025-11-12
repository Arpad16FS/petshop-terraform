output "public_ip" {
  description = "Public IP of the app instance"
  value       = aws_instance.app.public_ip
}

output "public_dns" {
  description = "Public DNS"
  value       = aws_instance.app.public_dns
}

output "web_url" {
  description = "HTTP URL"
  value       = "http://${aws_instance.app.public_ip}/"
}
