output "key_name" {
  description = "Name of the AWS key-pair"
  value       = aws_key_pair.kp.key_name
}

output "private_key_path" {
  description = "Local path to the private key file"
  value       = local_file.private.filename
}
