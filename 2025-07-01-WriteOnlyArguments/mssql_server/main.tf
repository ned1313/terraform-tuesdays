provider "azurerm" {
  features {}

}

resource "random_integer" "example" {
  min = 10000
  max = 99999
}

locals {
  name = "${var.prefix}-db-${random_integer.example.result}"
}

resource "azurerm_resource_group" "db" {
  name     = local.name
  location = "East US"
}

ephemeral "azurerm_key_vault_secret" "db_password_ephemeral" {
  name         = var.db_password_info.key_vault_secret_name
  key_vault_id = var.db_password_info.key_vault_id
}

resource "azurerm_mssql_server" "db" {
  name                                    = local.name
  resource_group_name                     = azurerm_resource_group.db.name
  location                                = azurerm_resource_group.db.location
  version                                 = "12.0"
  administrator_login                     = "mssqladmin"
  administrator_login_password_wo         = ephemeral.azurerm_key_vault_secret.db_password_ephemeral.value
  administrator_login_password_wo_version = var.db_password_info.version
}