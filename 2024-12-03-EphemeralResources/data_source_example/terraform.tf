terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.11"
    }
  }

  cloud {
    organization = "ned-in-the-cloud"
    workspaces {
      project = "terraform-tuesdays-demos"
      name    = "ephemeral-resources-data-source"
    }
  }
}