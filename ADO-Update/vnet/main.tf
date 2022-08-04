###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"

    }
  }

  backend "azurerm" {

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
  name = "${var.prefix}-${random_id.seed.hex}"
}

###########################
# RESOURCES
###########################

resource "random_id" "seed" {
  byte_length = 4
}

resource "azurerm_resource_group" "vnet" {
  name     = local.name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  name                = "ado-network"
  address_space       = ["10.42.0.0/24"]

  subnet {
    name           = "web"
    address_prefix = "10.42.0.0/24"
  }
}

resource "azurerm_network_security_group" "allow_ssh" {
  name                = "allow_ssh"
  location            = var.region
  resource_group_name = azurerm_resource_group.vnet.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
}
