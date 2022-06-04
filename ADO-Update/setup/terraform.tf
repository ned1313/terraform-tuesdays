terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"

    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }

  }
}