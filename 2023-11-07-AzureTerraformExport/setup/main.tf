provider "azurerm" {
  features {

  }
}

locals {
  # base naming convention for resources
  base_name = "tacotruck"
}

# Create a resource group for the network
resource "azurerm_resource_group" "network" {
  name     = "${local.base_name}-network"
  location = var.location
}

# Create a virtual network using the VNET module
module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"

  resource_group_name = azurerm_resource_group.network.name
  vnet_location       = azurerm_resource_group.network.location
  use_for_each        = true
  vnet_name           = local.base_name
  address_space       = ["10.42.0.0/16"]
  subnet_names        = ["web", "app", "data"]
  subnet_prefixes     = ["10.42.0.0/24", "10.42.1.0/24", "10.42.2.0/24"]
}

# Create a resource group for the VMs
resource "azurerm_resource_group" "vm" {
  name     = "${local.base_name}-vms"
  location = var.location
}

resource "random_id" "ip_dns" {
  byte_length = 4
}

# Create two virtual machines using the VM module
module "web_vms" {
  source  = "Azure/compute/azurerm"
  version = "5.3.0"

  resource_group_name           = azurerm_resource_group.vm.name
  vnet_subnet_id                = module.vnet.vnet_subnets_name_id["web"]
  vm_hostname                   = "${local.base_name}-web"
  location                      = azurerm_resource_group.vm.location
  admin_username                = "tacoadmin"
  admin_password                = "tacopassword123!"
  enable_ssh_key                = false
  vm_os_simple                  = "UbuntuServer"
  public_ip_dns                 = ["tacotruck-${random_id.ip_dns.hex}"]
  allocation_method             = "Static"
  public_ip_sku                 = "Standard"
  enable_accelerated_networking = true
  delete_os_disk_on_termination = true
  vm_size                       = "Standard_DS2_V2"
}

resource "azurerm_storage_account" "main" {
  resource_group_name      = azurerm_resource_group.vm.name
  location                 = azurerm_resource_group.vm.location
  name                     = "tacotruck${random_id.ip_dns.hex}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}