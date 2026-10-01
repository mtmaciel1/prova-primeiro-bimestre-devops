output "instance_id" {
  description = "ID da instancia"
  value       = aws_instance.api.id
}

output "public_ip" {
  description = "IP publico da EC2"
  value       = aws_instance.api.public_ip
}

output "public_dns" {
  description = "DNS publico da EC2"
  value       = aws_instance.api.public_dns
}

output "api_url" {
  description = "URL base da API"
  value       = "http://${aws_instance.api.public_ip}:${var.api_port}"
}