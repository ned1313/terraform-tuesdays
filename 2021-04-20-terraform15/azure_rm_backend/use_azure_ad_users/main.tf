terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    container_name = "state"
    key = "terraform.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  description = "Name of backend storage account."
  default     = "noscrubs"
}

variable "location" {
  description = "Azure location where resources should be deployed."
  default     = "eastus"
}


locals {
  name = "${lower(replace(var.prefix, "/[[:^alnum:]]/", ""))}-${random_id.seed.hex}"
}

data "azurerm_client_config" "current" {}

resource "random_id" "seed" {
  byte_length = 8
}

resource "azurerm_resource_group" "noscrubs" {
  location = var.location
  name = local.name
}