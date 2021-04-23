output "ec2_public_dns" {
  value = aws_instance.ec2[*].public_ip
}

output "vault_token" {
  value = nonsensitive(module.vault.vault_admin_token)
}

output "vault_private_ip_address" {
  value = module.vault.vault_private_endpoint_url
}