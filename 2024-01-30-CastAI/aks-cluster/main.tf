## Azure provider
provider "azurerm" {
  features {}
}

## First we need a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-castai"
  location = var.location
}

## And a virtual network
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.1.0"
  resource_group_name = azurerm_resource_group.main.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.main.location
  vnet_name           = "${var.prefix}-castai"
  address_space       = ["10.42.0.0/16"]
  subnet_names        = ["aks"]
  subnet_prefixes     = ["10.42.0.0/24"]
}

## We'll start by deploying an AKS cluster
module "aks" {
  source                            = "Azure/aks/azurerm"
  version                           = "7.5.0"
  resource_group_name               = azurerm_resource_group.main.name
  prefix                            = var.prefix
  role_based_access_control_enabled = true
  rbac_aad                          = false
  vnet_subnet_id                    = lookup(module.vnet.vnet_subnets_name_id, "aks")

  depends_on = [azurerm_resource_group.main]
}