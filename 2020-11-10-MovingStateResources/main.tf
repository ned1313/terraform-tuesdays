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

variable "tacos" {
  type        = string
  description = "prefix for naming"
  default     = "tacos"
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
  tacos = "${var.tacos}-demo"
  burritos = "${var.burritos}-demo"
}

###########################
# RESOURCES
###########################

resource "azurerm_resource_group" "tacos" {
  name     = local.tacos
  location = var.region
}

resource "azurerm_resource_group" "enchilada" {
  name     = local.burritos
  location = var.region
}

#module "tacos" {
#    source = "./tacos"
#    name = local.tacos
#    region = var.region
#}