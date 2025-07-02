output "db_password_info" {
  value = {
    key_vault_id          = azurerm_key_vault.example.id
    key_vault_secret_name = azurerm_key_vault_secret.write_only.name
    version               = nonsensitive(azurerm_key_vault_secret.write_only.value_wo_version)
  }
}