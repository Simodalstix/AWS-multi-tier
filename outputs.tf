output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "client_vpn_endpoint_id" {
  description = "Client VPN Endpoint ID"
  value       = aws_ec2_client_vpn_endpoint.vpn.id
}
