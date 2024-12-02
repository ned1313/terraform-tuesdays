output "name" {
  value = var.key_vault_id

}

output "secret_name" {
  value = var.key_vault_secret_name
}

#output "secret_value" {
#  value = nonsensitive(ephemeral.azurerm_key_vault_secret.example.value)
#}