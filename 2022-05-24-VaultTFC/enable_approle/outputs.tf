output "role_id" {
  value = vault_approle_auth_backend_role.tfc_dev.role_id
}

output "secret_id" {
  value = nonsensitive(vault_approle_auth_backend_role_secret_id.tfc_dev.secret_id)
}

output "role_path" {
  value = vault_auth_backend.approle.path
}
