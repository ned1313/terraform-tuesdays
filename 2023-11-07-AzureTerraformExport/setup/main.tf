provider "azurerm" {
  features {}
}

locals {
  base_name = "aztfy"
}

resource "azurerm_resource_group" "training" {
  name     = "RG-${local.base_name}"
  location = "East US"
}

resource "azurerm_virtual_network" "training" {
  name                = "${local.base_name}vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.training.location
  resource_group_name = azurerm_resource_group.training.name
}

resource "azurerm_subnet" "training" {
  name                 = "${local.base_name}sub"
  resource_group_name  = azurerm_resource_group.training.name
  virtual_network_name = azurerm_virtual_network.training.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "training" {
  name                    = "${local.base_name}ip"
  location                = azurerm_resource_group.training.location
  resource_group_name     = azurerm_resource_group.training.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
  domain_name_label       = "${local.base_name}domain"
}

resource "azurerm_network_interface" "training" {
  name                = "${local.base_name}ni"
  location            = azurerm_resource_group.training.location
  resource_group_name = azurerm_resource_group.training.name

  ip_configuration {
    name                          = "${local.base_name}ip"
    subnet_id                     = azurerm_subnet.training.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.training.id
  }
}

resource "azurerm_virtual_machine" "training" {
  name                  = "${local.base_name}vm"
  location              = azurerm_resource_group.training.location
  resource_group_name   = azurerm_resource_group.training.name
  network_interface_ids = [azurerm_network_interface.training.id]
  vm_size               = "Standard_D2s_v4"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"

  }
  storage_os_disk {
    name              = "${local.base_name}disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myserver"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.training.name
}