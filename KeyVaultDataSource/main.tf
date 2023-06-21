provider "azurerm" {
  features {}
}

variable "secret_name" {
  type        = string
  description = "Name of secret to retrieve from Key Vault"
}

variable "key_vault_id" {
  type        = string
  description = "ID of Key Vault holding the secret"
}

data "azurerm_key_vault_secret" "main" {
  name         = var.secret_name
  key_vault_id = var.key_vault_id
}