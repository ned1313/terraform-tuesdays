terraform {
  required_version = ">= 1.8.0"

  required_providers {
    # The root of the configuration where Terraform Apply runs should specify the maximum allowed provider version.
    # https://developer.hashicorp.com/terraform/language/providers/requirements#best-practices-for-provider-versions  
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.23"
    }
  }

}

provider "azapi" {
  enable_preflight = true
}

provider "azurerm" {
  features {}
}