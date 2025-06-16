variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "bastion_allowed_cidr" {
  description = "CIDR allowed to SSH to bastion"
  type        = string
}

variable "bastion_ami" {
  description = "AMI for bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH"
  type        = string
}

variable "client_vpn_root_cert_arn" {
  description = "ARN of root certificate for Client VPN authentication"
  type        = string
}

variable "client_vpn_server_cert_arn" {
  description = "ARN of the ACM server certificate for Client VPN"
  type        = string
}

variable "client_vpn_cidr" {
  description = "CIDR block for Client VPN clients"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS storage in GB"
  type        = number
}

variable "rds_engine_version" {
  description = "Postgres engine version"
  type        = string
}

variable "rds_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

variable "rds_db_name" {
  description = "Initial database name"
  type        = string
}

variable "rds_username" {
  description = "Master username for RDS"
  type        = string
}

variable "rds_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}
