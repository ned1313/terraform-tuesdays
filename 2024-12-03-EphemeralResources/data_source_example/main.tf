provider "azurerm" {
  features {}
  
}

data "azurerm_key_vault_secret" "example" {
  name = var.key_vault_secret_name
    key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_certificate" "example" {
  name = var.key_vault_certificate_name
    key_vault_id = var.key_vault_id
}