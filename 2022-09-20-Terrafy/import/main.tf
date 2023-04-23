resource "azurerm_resource_group" "res-0" {
  location = "eastus"
  name     = "RG-aztfy"
}
resource "azurerm_linux_virtual_machine" "res-1" {
  admin_username        = "tacoadmin"
  location              = "eastus"
  name                  = "tacoVM"
  network_interface_ids = ["/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/networkInterfaces/tacoVMVMNic"]
  resource_group_name   = "RG-aztfy"
  size                  = "Standard_DS1_v2"
  admin_ssh_key {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvL4jMQE+FhBUQ55+TLAYu30bzSqFSmLEs1oK53H97Yfmt1OQUBx4VqDc87rSA7Pq7pvA+LpurOJ/6Q7e80XxnZBGV8O3oKqbm2o8XIx90FsgolIcJeGl+gGsKblugAsQpMx7QIIo9PQxao8iTiaj7Hh/pfXmjyZ7mtSYvCLXba9W3Y1c1AQAmfSgDSnzUiNKwwscwAobhCOKgue211xC5FzPUjmIGdBVpgQpt+EeEjc5BkTx8CSZATjipcu3qrEGSsn0PaRn4A4xfCufpVCQnZyJ9InrheQg3c4ru5pGc1fTm14q5wcb2IKW0kyepFXEXby9YPnin8hZiGJaKdNbPg4h9oMp0qdzi2PoWfZeG772CV3pR/qAtrtyFamn9RFV9tQfcJqUpAkG3G66YxAH+GU4g1yNeYqQgymDvs6HNLHSLS6hFFqgAd40Z/R9ClyksvdYN2s7cRkSaFEvQbFQQRGx+xkHa3hSR6WGgtMvfghdt5Eu5mBfdYaYa3xICCh0= azuread\\nedbellavance@ned-office\n"
    username   = "tacoadmin"
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
    azurerm_network_interface.res-2,
  ]
}
resource "azurerm_network_interface" "res-2" {
  location            = "eastus"
  name                = "tacoVMVMNic"
  resource_group_name = "RG-aztfy"
  ip_configuration {
    name                          = "ipconfigtacoVM"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/publicIPAddresses/tacoVMPublicIP"
    subnet_id                     = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/virtualNetworks/tacoVMVNET/subnets/tacoVMSubnet"
  }
  depends_on = [
    azurerm_public_ip.res-5,
    azurerm_subnet.res-7,
    azurerm_network_security_group.res-3,
  ]
}
resource "azurerm_network_security_group" "res-3" {
  location            = "eastus"
  name                = "tacoVMNSG"
  resource_group_name = "RG-aztfy"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-4" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "default-allow-ssh"
  network_security_group_name = "tacoVMNSG"
  priority                    = 1000
  protocol                    = "Tcp"
  resource_group_name         = "RG-aztfy"
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-3,
  ]
}
resource "azurerm_public_ip" "res-5" {
  allocation_method   = "Dynamic"
  location            = "eastus"
  name                = "tacoVMPublicIP"
  resource_group_name = "RG-aztfy"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_virtual_network" "res-6" {
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  name                = "tacoVMVNET"
  resource_group_name = "RG-aztfy"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-7" {
  address_prefixes                               = ["10.0.0.0/24"]
  enforce_private_link_endpoint_network_policies = true
  name                                           = "tacoVMSubnet"
  resource_group_name                            = "RG-aztfy"
  virtual_network_name                           = "tacoVMVNET"
  depends_on = [
    azurerm_virtual_network.res-6,
  ]
}
