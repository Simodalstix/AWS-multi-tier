output "endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.this.endpoint
}

output "security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.this.id
}
