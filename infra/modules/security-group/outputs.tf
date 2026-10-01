output "ec2_sg_id" {
  description = "ID do Security Group da EC2 (usar no modulo ec2)"
  value       = aws_security_group.ec2.id
}

output "rds_sg_id" {
  description = "ID do Security Group do RDS (usar no modulo rds)"
  value       = aws_security_group.rds.id
}