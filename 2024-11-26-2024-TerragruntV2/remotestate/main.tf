###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"

    }
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "location" {
  type    = string
  default = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "tacos"
}

locals {
  resource_group_name  = "${var.naming_prefix}${random_integer.sa_num.result}"
  storage_account_name = "${lower(var.naming_prefix)}${random_integer.sa_num.result}"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

##################################################################################
# RESOURCES
##################################################################################
resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "setup" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name               = "terraform-state"
  storage_account_id = azurerm_storage_account.sa.id

}

##################################################################################
# OUTPUT
##################################################################################

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "container_name" {
  value = azurerm_storage_container.ct.name

}

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}