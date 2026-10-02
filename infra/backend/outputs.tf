output "bucket_name" {
  description = "Nome do bucket do state (copiar para o backend do infra/providers.tf)"
  value       = local.state_bucket_name
}

output "dynamodb_table_name" {
  description = "Nome da tabela de lock (copiar para o backend do infra/providers.tf)"
  value       = aws_dynamodb_table.lock.name
}