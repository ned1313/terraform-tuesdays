##################################################################################
# TERRAFORM CONFIG
##################################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
  #backend "azurerm" {
  #  key = "webapp"
  #}

  cloud {
    organization = "ned-in-the-cloud"
    workspaces {
      name = "tfc-migration-test"
    }
  }
}


##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  features {}
}