terraform {
  required_providers {
    tls = { source = "hashicorp/tls"
    version = "~> 4.0" }
    aws = { source = "hashicorp/aws"
    version = "~> 5.0" }
    local = { source = "hashicorp/local"
    version = "~> 2.0" }
    random = { source = "hashicorp/random"
    version = "~> 3.0" }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.key_name_prefix}-${random_id.suffix.hex}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private" {
  content         = tls_private_key.key.private_key_pem
  filename        = var.private_key_path
  file_permission = "0600"
}
