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

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "tacos"
}

variable "subnet_names" {
  type        = list(string)
  description = "list of subnet names"
  sensitive   = true
  default     = ["secret0", "secret1", "secret2"]
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
  name0 = "${var.prefix}-0"
  name1 = "${var.prefix}-1"
  name2 = "${var.prefix}-2"
}

###########################
# RESOURCES
###########################

resource "azurerm_resource_group" "vnet0" {
  name     = local.name0
  location = var.region
}

resource "azurerm_resource_group" "vnet1" {
  name     = local.name1
  location = var.region
}

resource "azurerm_resource_group" "vnet2" {
  name     = local.name2
  location = var.region
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "~> 3.0"
  resource_group_name = azurerm_resource_group.vnet0.name
  vnet_name           = local.name0
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["sub1","sub2","sub3"]

  tags = {
    environment = "dev"
    costcenter  = "finance"
  }

  depends_on = [azurerm_resource_group.vnet0]
}

