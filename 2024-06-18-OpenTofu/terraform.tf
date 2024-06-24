terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "tacoTruck"
    storage_account_name = "opentofu1313"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}