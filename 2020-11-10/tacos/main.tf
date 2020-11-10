###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"

    }
  }
}

###########################
# VARIABLES
###########################

variable "region" {
  type        = string
  description = "Region in Azure"
  default     = "eastus"
}

variable "name" {
  type        = string
  description = "name of resource group"
}

###########################
# PROVIDERS
###########################

provider "azurerm" {
  features {}
}

###########################
# RESOURCES
###########################

resource "azurerm_resource_group" "tacos" {
  name     = var.name
  location = var.region
}