// main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

// VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "multi-tier-vpc"
  }
}

// Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${count.index + 1}"
  }
}

// Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-${count.index + 1}"
  }
}

// Internet Gateway and Route Table for public
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

// Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Bastion Host
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  tags                   = { Name = "bastion-host" }
}

// Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_vpn_root_cert_arn
  }
  client_cidr_block      = var.client_vpn_cidr
  server_certificate_arn = var.client_vpn_server_cert_arn
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client_vpn.name
  }
  tags = { Name = "client-vpn" }
}

// RDS PostgreSQL
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnets"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = var.rds_allocated_storage
  engine                 = "postgres"
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  tags                   = { Name = "rds-postgres" }
}

// AWS Backup Vault
resource "aws_backup_vault" "main" {
  name = "main-backup-vault"
}

resource "aws_backup_plan" "plan" {
  name = "daily-backup"
  rule {
    rule_name         = "daily-snapshot"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)"
    lifecycle {
      cold_storage_after = 30
      delete_after       = 90
    }
  }
}

// CloudWatch Alarm & SNS
resource "aws_sns_topic" "alarms" {
  name = "alarm-topic"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

// Logging Best Practices: CloudTrail
resource "aws_s3_bucket" "trail_bucket" {
  bucket = "cloudtrail-logs-${var.aws_region}-${random_id.bucket_hex.hex}"
  acl    = "private"
}

resource "random_id" "bucket_hex" {
  byte_length = 4
}

resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
