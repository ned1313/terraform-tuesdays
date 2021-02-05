# Define provider for config
provider "azurerm" {
  version = "~> 2.0"
  features {}
}

# Used to get tenant ID as needed
data "azurerm_client_config" "current" {}

# Resource group for ALL resources
resource "azurerm_resource_group" "boundary" {
  name     = local.resource_group_name
  location = var.location
}

# Virtual network with three subnets for controller, workers, and backends
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version = "~> 2.0"
  resource_group_name = azurerm_resource_group.boundary.name
  vnet_name = azurerm_resource_group.boundary.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  subnet_service_endpoints = {
      (var.subnet_names[0]) = ["Microsoft.KeyVault"]
      (var.subnet_names[1]) = ["Microsoft.KeyVault"]
  }
}

# Create Network Security Groups for subnets
resource "azurerm_network_security_group" "controller_net" {
  name                = local.controller_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "worker_net" {
  name                = local.worker_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "backend_net" {
  name                = local.backend_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

# Create NSG associations
resource "azurerm_subnet_network_security_group_association" "controller" {
  subnet_id                 = module.vnet.vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.controller_net.id
}

resource "azurerm_subnet_network_security_group_association" "worker" {
  subnet_id                 = module.vnet.vnet_subnets[1]
  network_security_group_id = azurerm_network_security_group.worker_net.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = module.vnet.vnet_subnets[2]
  network_security_group_id = azurerm_network_security_group.backend_net.id
}

# Create Network Security Groups for NICs

resource "azurerm_network_security_group" "controller_nics" {
  name                = local.controller_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "worker_nics" {
  name                = local.worker_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_network_security_group" "backend_nics" {
  name                = local.backend_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

# Create application security groups for controllers and workers

resource "azurerm_application_security_group" "controller_asg" {
  name                = local.controller_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}

resource "azurerm_application_security_group" "worker_asg" {
  name                = local.worker_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
}