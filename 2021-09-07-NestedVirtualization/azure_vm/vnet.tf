resource "azurerm_resource_group" "vnet" {
  name     = local.name
  location = var.region
}

# Create a vnet with a single subnet for the Azure VM
module "network" {
  source              = "Azure/network/azurerm"
  version             = "~> 3.0"
  resource_group_name = azurerm_resource_group.vnet.name
  vnet_name           = local.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.0.0/24"]
  subnet_names        = ["hypervisors"]

  depends_on = [azurerm_resource_group.vnet]
}

# Create a network security group for the VM allowing SSH
resource "azurerm_network_security_group" "hypervisor_nics" {
  name                = local.hypervisor_vm
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
}

resource "azurerm_network_security_rule" "hypervisor_nic_ssh" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vnet.name
  network_security_group_name = azurerm_network_security_group.hypervisor_nics.name
}