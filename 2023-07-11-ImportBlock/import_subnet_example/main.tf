provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.azure_region
}

module "main" {
  source = "./network"

  resource_group_name = azurerm_resource_group.main.name
  azure_region        = azurerm_resource_group.main.location
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnets             = var.subnets
}