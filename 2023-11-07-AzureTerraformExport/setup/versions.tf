terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  cloud {
    organization = "ned-in-the-cloud"
    workspaces {
      name = "2023-11-07-AzureTerraformExport-Setup"
    }
  }
}