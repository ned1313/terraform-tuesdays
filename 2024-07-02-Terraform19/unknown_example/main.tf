terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
}

variable "primary_location" {
  type = string
  description = "Primary location for the resource group"
}

variable "partner_resource_group_id" {
  type = string
  description = "Partner resource group to use for deployment"

  validation {
    condition = azurerm_resource_group.main.id == var.partner_resource_group_id
    error_message = "Secondary resource group must be different from the primary resource group"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "main-resources"
  location = var.primary_location
}

resource "azurerm_resource_group" "partner" {
  name     = "partner-resources"
  location = var.partner_resource_group_id
}