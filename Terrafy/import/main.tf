resource "azurerm_public_ip" "res-0" {
  allocation_method       = "Dynamic"
  domain_name_label       = "aztfydomain"
  idle_timeout_in_minutes = 30
  location                = "eastus"
  name                    = "aztfyip"
  resource_group_name     = "RG-aztfy"
  depends_on = [
    azurerm_resource_group.res-5,
  ]
}
resource "azurerm_virtual_network" "res-1" {
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  name                = "aztfyvn"
  resource_group_name = "RG-aztfy"
  depends_on = [
    azurerm_resource_group.res-5,
  ]
}
resource "azurerm_virtual_machine" "res-1" {
  location              = "eastus"
  name                  = "aztfyvm"
  network_interface_ids = ["/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/networkInterfaces/aztfyni"]
  resource_group_name   = "RG-aztfy"
  tags = {
    environment = "staging"
  }
  vm_size = "Standard_D2s_v4"
  os_profile {
    admin_username = "testadmin"
    computer_name  = "myserver"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_os_disk {
    create_option = "FromImage"
    name          = "aztfydisk"
  }
  depends_on = [
    azurerm_network_interface.res-4,
  ]
}
resource "azurerm_subnet" "res-3" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "aztfysub"
  resource_group_name  = "RG-aztfy"
  virtual_network_name = "aztfyvn"
  depends_on = [
    azurerm_virtual_network.res-1,
  ]
}
resource "azurerm_network_interface" "res-4" {
  location            = "eastus"
  name                = "aztfyni"
  resource_group_name = "RG-aztfy"
  ip_configuration {
    name                          = "aztfyip"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/publicIPAddresses/aztfyip"
    subnet_id                     = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/RG-aztfy/providers/Microsoft.Network/virtualNetworks/aztfyvn/subnets/aztfysub"
  }
  depends_on = [
    azurerm_public_ip.res-0,
    azurerm_subnet.res-3,
  ]
}
resource "azurerm_resource_group" "res-5" {
  location = "eastus"
  name     = "RG-aztfy"
}