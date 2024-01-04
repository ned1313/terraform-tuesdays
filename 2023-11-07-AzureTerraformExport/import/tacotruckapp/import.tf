import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/TACOTRUCK-VMS/providers/Microsoft.Compute/virtualMachines/TACOTRUCK-WEB-VMLINUX-0"
  to = azurerm_linux_virtual_machine.res-0
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms"
  to = azurerm_resource_group.res-1
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Compute/availabilitySets/tacotruck-web-avset"
  to = azurerm_availability_set.res-2
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Compute/virtualMachines/tacotruck-web-vmLinux-0/providers/Microsoft.Authorization/roleAssignments/95d53145-0d3b-4c15-9c9f-e102ca9dd935"
  to = azurerm_role_assignment.res-3
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkInterfaces/tacotruck-web-nic-0"
  to = azurerm_network_interface.res-4
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkInterfaces/tacotruck-web-nic-0|/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkSecurityGroups/tacotruck-web-nsg"
  to = azurerm_network_interface_security_group_association.res-5
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkSecurityGroups/tacotruck-web-nsg"
  to = azurerm_network_security_group.res-6
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/publicIPAddresses/tacotruck-web-pip-0"
  to = azurerm_public_ip.res-7
}
import {
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Storage/storageAccounts/tacotruckc997e06f"
  to = azurerm_storage_account.res-8
}
