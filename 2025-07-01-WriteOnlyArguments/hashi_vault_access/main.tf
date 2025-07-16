provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "azurerm" {
  features {}
}

resource "random_integer" "example" {
  min = 10000
  max = 99999

}

locals {
  name = "vault-ephemeral-${random_integer.example.result}"
}

resource "azurerm_resource_group" "example" {
  name     = local.name
  location = "East US"
}

data "azurerm_client_config" "example" {

}

resource "azurerm_key_vault" "example" {
  name                = local.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.example.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.example.tenant_id
    object_id = data.azurerm_client_config.example.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
    ]
  }

}

ephemeral "vault_kv_secret_v2" "burrito_recipe" {
  mount = var.secret_mount_path
  name  = var.secret_name
  version = var.secret_version
}

# Write the secret to Azure Key Vault
resource "azurerm_key_vault_secret" "write_only" {
  name             = "burrito-recipe"
  value_wo         = jsonencode(ephemeral.vault_kv_secret_v2.burrito_recipe.data)
  #value_wo = ephemeral.vault_kv_secret_v2.burrito_recipe.data_json
  value_wo_version = var.secret_version
  key_vault_id     = azurerm_key_vault.example.id
}