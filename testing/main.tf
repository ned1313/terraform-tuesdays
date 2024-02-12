provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "${var.naming_prefix}-tf201"
  vnet_name           = "${var.naming_prefix}-tf201"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = var.common_tags
}

module "network" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"

  resource_group_name = azurerm_resource_group.main.name
  vnet_location       = azurerm_resource_group.main.location
  use_for_each        = true

  vnet_name     = local.vnet_name
  address_space = var.vnet_address_space

  subnet_names    = keys(var.subnet_configuration)
  subnet_prefixes = values(var.subnet_configuration)

  tags = var.common_tags
}