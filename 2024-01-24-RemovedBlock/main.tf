terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~>3.0"
        }
    }
    
}

provider "azurerm" {
  features {}
}

#resource "azurerm_resource_group" "rg" {
#  name     = "remove-me"
#  location = "eastus"
#}

removed {
  from = azurerm_resource_group.rg

  lifecycle {
    destroy = false
  }
}