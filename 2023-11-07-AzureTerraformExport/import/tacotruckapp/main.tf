resource "azurerm_linux_virtual_machine" "res-0" {
  admin_password                  = "ignored-as-imported1234!"
  admin_username                  = "tacoadmin"
  availability_set_id             = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/TACOTRUCK-VMS/providers/Microsoft.Compute/availabilitySets/TACOTRUCK-WEB-AVSET"
  disable_password_authentication = false
  location                        = "eastus"
  name                            = "TACOTRUCK-WEB-VMLINUX-0"
  network_interface_ids           = ["/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkInterfaces/tacotruck-web-nic-0"]
  resource_group_name             = "TACOTRUCK-VMS"
  size                            = "Standard_DS2_v2"
  tags = {
    source = "terraform"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.res-4,
  ]
}
resource "azurerm_resource_group" "res-1" {
  location = "eastus"
  name     = "tacotruck-vms"
}
resource "azurerm_availability_set" "res-2" {
  location                     = "eastus"
  name                         = "tacotruck-web-avset"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  resource_group_name          = "tacotruck-vms"
  tags = {
    source = "terraform"
  }
}
resource "azurerm_role_assignment" "res-3" {
  principal_id = "f187b12c-5f05-4200-a489-4072116ea290"
  role_definition_name = "Contributor"
  scope        = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Compute/virtualMachines/tacotruck-web-vmLinux-0"
}
resource "azurerm_network_interface" "res-4" {
  enable_accelerated_networking = true
  location                      = "eastus"
  name                          = "tacotruck-web-nic-0"
  resource_group_name           = "tacotruck-vms"
  tags = {
    source = "terraform"
  }
  ip_configuration {
    name                          = "tacotruck-web-ip-0"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/publicIPAddresses/tacotruck-web-pip-0"
    subnet_id                     = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-network/providers/Microsoft.Network/virtualNetworks/tacotruck/subnets/web"
  }
  depends_on = [
    azurerm_public_ip.res-7,
  ]
}
resource "azurerm_network_interface_security_group_association" "res-5" {
  network_interface_id      = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkInterfaces/tacotruck-web-nic-0"
  network_security_group_id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacotruck-vms/providers/Microsoft.Network/networkSecurityGroups/tacotruck-web-nsg"
  depends_on = [
    azurerm_network_interface.res-4,
    azurerm_network_security_group.res-6,
  ]
}
resource "azurerm_network_security_group" "res-6" {
  location            = "eastus"
  name                = "tacotruck-web-nsg"
  resource_group_name = "tacotruck-vms"
  tags = {
    source = "terraform"
  }
}
resource "azurerm_public_ip" "res-7" {
  allocation_method   = "Static"
  domain_name_label   = "tacotruck-c997e06f"
  location            = "eastus"
  name                = "tacotruck-web-pip-0"
  resource_group_name = "tacotruck-vms"
  sku                 = "Standard"
  tags = {
    source = "terraform"
  }
}
resource "azurerm_storage_account" "res-8" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = "eastus"
  name                     = "tacotruckc997e06f"
  resource_group_name      = "tacotruck-vms"
}
