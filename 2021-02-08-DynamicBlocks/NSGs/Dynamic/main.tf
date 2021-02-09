# In this example we will create a basic VNet and then an NSG for
# one of the subnets. This is one way to do it, and we are going
# to parse some JSON to create a dynamic set of blocks

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
# LOCALS
###########################

locals {
  rules = jsondecode(file("rules.json")).Rules
  rule_mapping = {
      vnet = var.address_space
      private = "${data.http.my_ip.body}/32"
      subnet = var.subnet_prefixes[0]
      all = "*"
  }
}

###########################
# DATA
###########################

data "http" "my_ip" {
  url = "http://ifconfig.me"
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

  dynamic "subnet" {
    for_each = zipmap(var.subnet_names,var.subnet_prefixes)
      content {
          name = subnet.key
          address_prefix = subnet.value
      }
  }
}

resource "azurerm_network_security_group" "public" {
    name = "publicSubnet"
    location = azurerm_resource_group.vnet.location
    resource_group_name = azurerm_resource_group.vnet.name

    dynamic "security_rule" {
        for_each = local.rules 
        content {
            name = security_rule.value["name"]
            priority = security_rule.value["priority"]
            direction = security_rule.value["direction"]
            access = security_rule.value["access"]
            protocol = security_rule.value["protocol"]
            source_port_range = security_rule.value["source_port_range"]
            destination_port_range = security_rule.value["destination_port_range"]
            source_address_prefix = local.rule_mapping[security_rule.value["source_address_prefix"]]
            destination_address_prefix = local.rule_mapping[security_rule.value["destination_address_prefix"]]
        }
    }
}