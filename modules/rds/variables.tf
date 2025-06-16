variable "vpc_id" {
  description = "VPC ID for RDS placement"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnets"
  type        = list(string)
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "Postgres engine version"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS storage (GB)"
  type        = number
}

variable "bastion_sg_id" {
  description = "Security Group ID of the bastion host"
  type        = string
}
