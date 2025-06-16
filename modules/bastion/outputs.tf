output "security_group_id" {
  description = "Security Group ID of the bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "instance_id" {
  description = "ID of the bastion EC2 instance"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}
