# Deploy and Azure Virtual Machine running Ubuntu 22.04
# Include a Public IP address and DNS name

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "check-block-example"
  location = "West US"
}

module "main_network" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"

  resource_group_name = azurerm_resource_group.example.name
  vnet_location       = azurerm_resource_group.example.location
  use_for_each        = true
  vnet_name           = "check-network"
  address_space       = ["10.42.0.0/16"]
  subnet_names        = ["web"]
  subnet_prefixes     = ["10.42.0.0/24"]

}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.example.location
  name                = "check-pip"
  resource_group_name = azurerm_resource_group.example.name
}

module "ubuntu_server" {
  source  = "Azure/virtual-machine/azurerm"
  version = "1.0.0"

  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_D2s_v4"
  subnet_id           = module.main_network.vnet_subnets_name_id["web"]
  image_os            = "linux"
  os_simple           = "UbuntuServer"
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  location = azurerm_resource_group.example.location
  name     = "check-vm"

  new_network_interface = {
    ip_forwarding_enabled = false
    ip_configurations = [
      {
        public_ip_address_id = azurerm_public_ip.pip.id
        primary              = true
      }
    ]
  }

  admin_username = "azureuser"
  admin_ssh_keys = [
    {
      public_key = tls_private_key.ssh.public_key_openssh
    }
  ]

  custom_data = base64encode(templatefile("${path.module}/userdata.tpl", {}))

}

resource "azurerm_network_security_group" "allow_web" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "check-example"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.allow_web.name
}

resource "azurerm_network_interface_security_group_association" "allow_web" {
  network_interface_id      = module.ubuntu_server.network_interface_id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}

data "azurerm_public_ip" "pip" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_resource_group.example.name

  depends_on = [module.ubuntu_server]
}