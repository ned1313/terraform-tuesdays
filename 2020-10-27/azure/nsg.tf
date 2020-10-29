# Inbound rules for controller subnet nsg

resource "azurerm_network_security_rule" "controller_9200" {
  name                        = "allow_9200"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9200"
  source_address_prefix       = "*"
  destination_application_security_group_ids  = [azurerm_application_security_group.controller_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.controller_net.name
}

resource "azurerm_network_security_rule" "controller_9201" {
  name                        = "allow_9201"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9201"
  source_application_security_group_ids      = [azurerm_application_security_group.worker_asg.id]
  destination_application_security_group_ids  = [azurerm_application_security_group.controller_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.controller_net.name
}

# Inbound rules for controller nic nsg

resource "azurerm_network_security_rule" "controller_nic_9200" {
  name                        = "allow_9200"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9200"
  source_address_prefix       = "*"
  destination_application_security_group_ids  = [azurerm_application_security_group.controller_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.controller_nics.name
}

resource "azurerm_network_security_rule" "controller_nic_9201" {
  name                        = "allow_9201"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9201"
  source_application_security_group_ids      = [azurerm_application_security_group.worker_asg.id]
  destination_application_security_group_ids  = [azurerm_application_security_group.controller_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.controller_nics.name
}

# Inbound rules for worker subnet nsg

resource "azurerm_network_security_rule" "worker_9202" {
  name                        = "allow_9202"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9202"
  source_address_prefix       = "*"
  destination_application_security_group_ids  = [azurerm_application_security_group.worker_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.worker_net.name
}

# Inbound rules for worker nic nsg

resource "azurerm_network_security_rule" "worker_nic_9202" {
  name                        = "allow_9202"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9202"
  source_address_prefix       = "*"
  destination_application_security_group_ids  = [azurerm_application_security_group.worker_asg.id]
  resource_group_name         = azurerm_resource_group.boundary.name
  network_security_group_name = azurerm_network_security_group.worker_nics.name
}

# Inbound rules for backend subnet nsg

# None for right now