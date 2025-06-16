variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the bastion"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
}

variable "ssh_source_cidr" {
  description = "CIDR block allowed to SSH to the bastion"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair to use"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the bastion instance from"
  type        = string
}
