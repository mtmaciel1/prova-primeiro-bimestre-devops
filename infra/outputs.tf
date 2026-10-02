output "ec2_public_ip" {
  description = "IP publico da EC2"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS (host:porta)"
  value       = module.rds.endpoint
}

output "api_url" {
  description = "URL da API de Reservas"
  value       = module.ec2.api_url
}