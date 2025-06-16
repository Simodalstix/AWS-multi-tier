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

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
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
  description = "RDS instance class"
  type        = string
}

variable "rds_db_name" {
  description = "Initial database name"
  type        = string
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
}

variable "rds_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "log_retention_days" {
  description = "Days to retain CloudWatch Logs"
  type        = number
  default     = 14
}

variable "ssh_source_cidr" {
  description = "CIDR block allowed to SSH to the bastion host"
  type        = string
  default     = "163.47.120.158/32" # My IP 
}
