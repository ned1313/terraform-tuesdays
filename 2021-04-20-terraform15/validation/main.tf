terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.46.1"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "main" {
  name     = "test"
  location = "eastus"
  #colors   = ["blue"]
}

module "network" {
  source        = "Azure/network/azurerm"
  version       = "~> 3.3.0"
  vnet_name     = "The best name ever!"
  address_space = 24
  #resource_group_name    = azurerm_resource_group.main.group
  resource_group_name    = azurerm_resource_group.main.name
}