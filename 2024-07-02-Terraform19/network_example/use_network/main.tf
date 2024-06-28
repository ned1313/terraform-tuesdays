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


data "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"

  validation {
    condition     = contains(data.azurerm_virtual_network.main.subnets, var.subnet_name)
    error_message = "Subnet name must be in the list of subnets from the virtual network."
  }

}