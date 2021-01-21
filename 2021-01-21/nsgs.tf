resource "azurerm_network_security_rule" "controller_nic_ssh" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.cka.name
  network_security_group_name = azurerm_network_security_group.controller_nics.name
}

resource "azurerm_network_security_rule" "controller_nic_allow_worker" {
    name = "allow_worker"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = var.address_space[0]
    destination_address_prefix = "*"
    resource_group_name         = azurerm_resource_group.cka.name
  network_security_group_name = azurerm_network_security_group.controller_nics.name
}

resource "azurerm_network_security_rule" "worker_nic_ssh" {
  name                        = "allow_ssh_local"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.cka.name
  network_security_group_name = azurerm_network_security_group.worker_nics.name
}

resource "azurerm_network_security_rule" "worker_nic_allow_controller" {
    name = "allow_controller"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = var.address_space[0]
    destination_address_prefix = "*"
    resource_group_name         = azurerm_resource_group.cka.name
  network_security_group_name = azurerm_network_security_group.worker_nics.name
}

