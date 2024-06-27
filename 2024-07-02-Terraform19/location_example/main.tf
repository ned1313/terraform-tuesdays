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

variable "location" {
  type = string
  description = "Location for the resource group"
}

variable "partner_location" {
  type = string
  description = "Partner location to use for deployment"

  validation {
    condition = var.partner_location != var.location
    error_message = "Partner location must be different from the resource group location"
  }
  
}

resource "azurerm_resource_group" "main" {
  name     = "main-resources"
  location = var.location
}

resource "azurerm_resource_group" "partner" {
  name     = "partner-resources"
  location = var.partner_location
}