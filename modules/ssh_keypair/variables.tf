variable "key_name_prefix" {
  description = "Prefix to use for the EC2 key-pair name"
  type        = string
  default     = "tf-bastion"
}

variable "private_key_path" {
  description = "File path to write the private key"
  type        = string
  default     = "bastion.pem"
}

variable "rsa_bits" {
  description = "Size of the RSA key in bits"
  type        = number
  default     = 4096
}
