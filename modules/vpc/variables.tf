variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs to place subnets in"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}
