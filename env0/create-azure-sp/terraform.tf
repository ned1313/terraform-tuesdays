terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
        source = "hashicorp/azuread"
        version = "~> 2.0"
    }
  }
}