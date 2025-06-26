# main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "random" {}

provider "azurerm" {
  features {}
}

locals {
  allowed_locations = ["East US", "West US", "Central US"]
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "East US"
  validation {
    condition     = contains(local.allowed_locations, var.location)
    error_message = "Location must be one of ${join(local.allowed_locations, ", ")}."
  }
}

variable "dr_location" {
  description = "The Azure region for disaster recovery."
  type        = string
  default     = "West US"
  validation {
    condition     = contains(local.allowed_locations, var.dr_location)
    error_message = "Disaster recovery location must be one of ${join(local.allowed_locations, ", ")}."
  }
  validation {
    condition     = var.location != var.dr_location
    error_message = "Disaster recovery location must be different from the primary location."
  }
}

# Identifier is azurerm_resource_group.main
resource "azurerm_resource_group" "main" {
  name     = "my-awesome-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "my-awesome-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    precondition {
      condition     = startswith(local.storage_account_name, "stg")
      error_message = "Storage account name must start with 'stg'."
    }

    precondition {
      condition     = length(local.storage_account_name) <= 24
      error_message = "Storage account name must not exceed 24 characters."
    }
  }
}

data "azurerm_resource_group" "example" {
  name = var.resource_group_name

  lifecycle {
    postcondition {
      condition     = contains(["eastus", "westus2"], self.location)
      error_message = "Resource group must be located in ${var.location}."
    }
  }
}