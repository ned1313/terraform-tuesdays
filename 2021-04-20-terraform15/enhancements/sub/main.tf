terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
      configuration_aliases = [ azurerm.sub ]
    }
  }
}
 
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "alias" {
  name = "alias-rg"
  location = "eastus"
  provider = azurerm.sub
}

resource "azurerm_resource_group" "default" {
  name = "default-rg"
  location = "eastus"
}