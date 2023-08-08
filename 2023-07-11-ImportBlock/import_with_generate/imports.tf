# Virtual network
import {
    to = azurerm_virtual_network.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/virtualNetworks/tacoNet"
}

# Subnet
import {
    to = azurerm_subnet.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/virtualNetworks/tacoNet/subnets/Subnet"
}

# Public IP
import {
    to = azurerm_public_ip.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/publicIPAddresses/tacoVMPublicIP"
}

# Network Interface
import {
    to = azurerm_network_interface.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt"
}

# NSG
import {
    to = azurerm_network_security_group.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkSecurityGroups/SecGroupNet"
}

# NSG Association uses NICID|NSGID format
import {
    to = azurerm_network_interface_security_group_association.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt|/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkSecurityGroups/SecGroupNet"
}

# VM
import {
    to = azurerm_linux_virtual_machine.main
    id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Compute/virtualMachines/tacoVM"
}




import {
    to = "RESOURCE_ADDRESS"
    id = "UNIQUE_IDENTIFIER"
}