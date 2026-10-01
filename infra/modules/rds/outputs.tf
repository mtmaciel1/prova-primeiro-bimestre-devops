output "address" {
  description = "Hostname do RDS sem porta (alimenta db_host da EC2)"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Porta do RDS (alimenta db_port da EC2)"
  value       = aws_db_instance.this.port
}

output "endpoint" {
  description = "Endpoint completo host:porta (apenas informativo, para o output final)"
  value       = aws_db_instance.this.endpoint
}