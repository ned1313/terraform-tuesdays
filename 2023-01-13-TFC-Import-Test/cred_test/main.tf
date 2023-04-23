terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 3.0"
        }
    }

    cloud {
    organization = "ned-in-the-cloud"

    workspaces {
      name = "azure-cred-test"
    }
  }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "main" {
  name = "import-test"
  location = "East US"
}