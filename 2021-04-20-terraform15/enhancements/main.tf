terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

variable "location" {
  type    = string
  default = "eastus"
}

provider "azurerm" {
  features {}
  alias = "sub"
}

module "sub" {
  source = "./sub"
  providers = {
    azurerm.sub = azurerm.sub
  }
}

locals {
  unnecessary_interpolation = var.location
}