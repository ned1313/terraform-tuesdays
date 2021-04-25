output "ec2_public_dns" {
  value = aws_instance.ec2[*].public_ip
}

output "vault_token" {
  value = nonsensitive(module.vault.vault_admin_token)
}

output "vault_private_ip_address" {
  value = module.vault.vault_private_endpoint_url
}

output "consul_token" {
  value = nonsensitive(module.consul.consul_admin_token)
}

output "consul_private_ip_address" {
  value = module.consul.consul_private_endpoint_url
}