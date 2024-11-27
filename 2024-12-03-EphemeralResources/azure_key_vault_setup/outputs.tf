output "secret_name" {
  value       = azurerm_key_vault_secret.example.name
  description = "The name of the secret in the Azure Key Vault."

}

output "certificate_name" {
  value       = azurerm_key_vault_certificate.example.name
  description = "The name of the certificate in the Azure Key Vault."
}

output "key_vault_id" {
  value       = azurerm_key_vault.example.id
  description = "The ID of the Azure Key Vault."
}