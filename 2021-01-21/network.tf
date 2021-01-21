terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.41.0"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "cka" {
    name = "cka"
    location = var.location
}

# Virtual network with three subnets for controller, workers, and backends
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version = "~> 2.0"
  resource_group_name = azurerm_resource_group.cka.name
  vnet_name = azurerm_resource_group.cka.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  depends_on = [ azurerm_resource_group.cka ]
}

# Create Network Security Groups for NICs

resource "azurerm_network_security_group" "controller_nics" {
  name                = local.controller_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name
}

resource "azurerm_network_security_group" "worker_nics" {
  name                = local.worker_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name
}