provider "azurerm" {
  features {}
  #subscription_id = var.subscription_id
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID to use for Azure resources"
}

resource "azurerm_resource_group" "example" {
  name     = "function-example-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "function-example-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

output "parsed_id_rg" {
  value = provider::azurerm::parse_resource_id(azurerm_resource_group.example.id)
}

output "parsed_id_vnet" {
  value = provider::azurerm::parse_resource_id(azurerm_virtual_network.example.id)
}