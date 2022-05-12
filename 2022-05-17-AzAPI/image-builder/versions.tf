terraform {
  required_version = "~>1.0"

  required_providers {
    azurerm = {
      version = "~>3.0"
      source  = "hashicorp/azurerm"
    }

    azapi = {
      version = "~>0.0"
      source  = "azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
}