provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.website_name}-staging-rg"
  location = var.location
}

locals {
  storage_account_name = "${lower(replace(var.website_name, "/[[:^alnum:]]/", ""))}data001"
}

resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  timeouts {
    delete = "5m"
  }
}

resource "azurerm_storage_container" "main" {
  name                  = "wwwroot"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "homepage" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.main.name
  source                 = var.html_path
  type                   = "Block"
  content_type           = "text/html"
}