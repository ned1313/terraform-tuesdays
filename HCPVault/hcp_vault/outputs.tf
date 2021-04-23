output "vault_private_endpoint_url" {
  value = hcp_vault_cluster.vault.vault_private_endpoint_url
}

output "vault_public_endpoint_url" {
  value = hcp_vault_cluster.vault.vault_public_endpoint_url
}

output "vault_admin_token" {
  value = hcp_vault_cluster_admin_token.vault.token
  sensitive = true
}