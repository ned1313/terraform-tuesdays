###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"

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

variable "resource_group_name" {
  type        = string
  description = "Name of resource group to create."
  default     = "tacos"
}

variable "vnet_name" {
  description = "Name of the vnet to create."
  type        = string
  default     = "taconet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = ["subnet1","subnet2"]
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

resource "azurerm_resource_group" "vnet" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  address_space       = [var.address_space]
  #tags = {
  #  environment = "dev"
  #}
}

resource "azurerm_subnet" "subnets" {
    count = length(var.subnet_names)
    name = var.subnet_names[count.index]
    resource_group_name = azurerm_resource_group.vnet.name
    address_prefixes = [ var.subnet_prefixes[count.index] ]
    virtual_network_name = azurerm_virtual_network.vnet.name
}

