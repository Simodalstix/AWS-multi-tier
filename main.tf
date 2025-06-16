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

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "vpc" {
  source                = "./modules/vpc"
  aws_region            = var.aws_region
  availability_zones    = var.availability_zones
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
}

module "bastion" {
  source            = "./modules/bastion"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.bastion_instance_type
  ssh_source_cidr   = var.ssh_source_cidr
  key_name          = module.bastion_key.key_name
  ami_id            = data.aws_ami.amazon_linux2.id
}

module "bastion_key" {
  source           = "./modules/ssh_keypair"
  key_name_prefix  = "simo-bastion"
  private_key_path = "bastion.pem"
}

output "bastion_private_key_path" {
  value = module.bastion_key.private_key_path
}

output "bastion_public_ip" {
  value       = module.bastion.public_ip
  description = "Public IP of the bastion host"
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name           = var.rds_db_name
  username          = var.rds_username
  password          = var.rds_password
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage

  bastion_sg_id = module.bastion.security_group_id
}

module "backup" {
  source             = "./modules/backup"
  backup_vault_name  = "main-backup-vault"
  plan_name          = "daily-backup"
  rule_name          = "daily-snapshot"
  schedule           = "cron(0 5 * * ? *)"
  cold_storage_after = 30
  delete_after       = 120
}

// Monitoring & Alerts
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

// CloudTrail Logging
resource "random_id" "bucket_hex" {
  byte_length = 4
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "cloudtrail-logs-${var.aws_region}-${random_id.bucket_hex.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "trail_block" {
  bucket                  = aws_s3_bucket.trail_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

// After your aws_cloudtrail resource…
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid    = "AllowCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail_bucket.arn]
  }

  statement {
    sid    = "AllowCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AllowCloudTrailListBucket"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.trail_bucket.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}
