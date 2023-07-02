# Virtual network
import {
    to = azurerm_virtual_network.main
    id = "VPC"
}

# Subnet
import {
    to = azurerm_subnet.main
    id = "SUBNET"
}

# Public IP
import {
    to = azurerm_public_ip.main
    id = "PublicIP"
}

# Network Interface
import {
    to = azurerm_network_interface.main
    id = "NIC"
}

# NSG
import {
    to = azurerm_network_security_group.main
    id = "NSG"
}

# NSG Association uses NICID|NSGID format
import {
    to = azurerm_network_interface_security_group_association.main
    id = "NICID|NSGID"
}

# VM
import {
    to = azurerm_linux_virtual_machine.main
    id = "VM
}