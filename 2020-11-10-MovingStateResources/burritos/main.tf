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

variable "burritos" {
  type        = string
  description = "prefix for naming"
  default     = "burritos"
}

###########################
# PROVIDERS
###########################

provider "azurerm" {
  features {}
}

###########################
# DATA SOURCES
###########################

locals {
  burritos = "${var.burritos}-demo"
}

###########################
# RESOURCES
###########################

resource "azurerm_resource_group" "burrito" {
  name     = local.burritos
  location = var.region
}
