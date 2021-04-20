terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  name = "${lower(replace(var.prefix, "/[[:^alnum:]]/", ""))}${random_id.seed.hex}"
}

data "azurerm_client_config" "current" {}

resource "random_id" "seed" {
  byte_length = 4
}

resource "azurerm_resource_group" "state" {
  name     = local.name
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                = local.name
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location

  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "state" {
  name                  = "state"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"

}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.state.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}