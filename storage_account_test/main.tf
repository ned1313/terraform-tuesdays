variable "subscription_id" {
  type = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "random_string" "random_id" {
  length  = 6
  special = false
}

# Create resource group
resource "azurerm_resource_group" "test" {
  name     = "testResourceGroup"
  location = "East US"
}

# Create storage account
resource "azurerm_storage_account" "test" {
  name                     = "testsa${lower(random_string.random_id.result)}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create output of storage account name
output "storage_account_name" {
  value = azurerm_storage_account.test.name
}