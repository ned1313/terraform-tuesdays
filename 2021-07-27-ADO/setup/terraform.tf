terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.1.8"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"

    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.13.0"
    }
  }
}