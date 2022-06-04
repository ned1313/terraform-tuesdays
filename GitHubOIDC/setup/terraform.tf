terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }

    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}