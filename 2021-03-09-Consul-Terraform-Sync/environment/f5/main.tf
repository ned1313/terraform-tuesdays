variable "location" {
  type = string
  description = "Location in Azure for resources"
  default = "eastus"
}

variable "resource_group_name" {}

variable "subnet_id" {}

variable "adminUsername" {
  default = "azureuser"
}

variable "ssh_key" {}

variable "vmSize" {
  default = "Standard_D2as_V4"
}

variable "imageReference" {
  default = {
      publisher = "f5-networks"
      offer = "f5-big-ip-per-app-ve"
      sku = "f5-big-awf-plus-pve-hourly-200mbps"
      version = "latest"
  }
}

variable "storageAccountType" {
  default = "StandardSSD_LRS"
}

provider "azurerm" {
  features {}
}

resource "azurerm_network_security_group" "bigip" {
  name                = "bigIPNSG"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bigip.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bigip.name
}

resource "azurerm_network_security_rule" "mgmt" {
  name                        = "mgmt"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bigip.name
}

resource "azurerm_public_ip" "bigip" {
  name                = "bigIpPublicIp"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "bigip" {
  name = "bigipnic"
  resource_group_name = var.resource_group_name
  location = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.bigip.id
  }

}

resource "azurerm_network_interface_security_group_association" "bigip" {
  network_interface_id      = azurerm_network_interface.bigip.id
  network_security_group_id = azurerm_network_security_group.bigip.id
}

resource "azurerm_linux_virtual_machine" "bigip" {
  name = "bigipVM"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vmSize
  admin_username      = var.adminUsername
  network_interface_ids = [
    azurerm_network_interface.bigip.id,
  ]

  admin_ssh_key {
    username   = var.adminUsername
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storageAccountType
  }

  source_image_reference {
    publisher = var.imageReference.publisher
    offer     = var.imageReference.offer
    sku       = var.imageReference.sku
    version   = "latest"
  }

  plan {
    name = var.imageReference.sku
    product = var.imageReference.offer
    publisher = var.imageReference.publisher
  }
}

output "private_ip_address" {
  value = azurerm_network_interface.bigip.private_ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.bigip.ip_address
}