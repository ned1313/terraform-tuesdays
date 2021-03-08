# Variables

variable "prefix" {
  type = string
  description = "Naming prefix for all resources"
  default = "taco"
}

variable "location" {
  type = string
  description = "Location in Azure for resources"
  default = "eastus"
}

variable "big_ip_password" {
    type = string
    description = "Password for BIGIP appliance after provisioning"
    default = "hg5678uhju8765trgfr567u876tghfr56"
}

# Providers

provider "azurerm" {
  features {}
}

locals {
  rg_name = "${var.prefix}-cts"
  cts_hostname = "${var.prefix}-cts-vm"
}

# Resources

# Generate key pair for all VMs
resource "tls_private_key" "boundary" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  content  = tls_private_key.boundary.private_key_pem
  filename = "${path.root}/cts_private_key.pem"
}

resource "azurerm_resource_group" "cts" {
  name = local.rg_name
  location = var.location
}

# Create Vnet

module "network" {
  source  = "Azure/network/azurerm"
  version = "~>3.0"
  resource_group_name = azurerm_resource_group.cts.name
  address_space = "10.0.0.0/16"
  subnet_prefixes = ["10.0.0.0/24"]
  subnet_names = ["main"]

  depends_on = [ azurerm_resource_group.cts ]
}

# Create BIG-IP appliance

module "bigip" {
  source = "./f5"
  location = var.location
  resource_group_name = azurerm_resource_group.cts.name
  subnet_id = module.network.vnet_subnets[0]
  ssh_key = tls_private_key.boundary.public_key_openssh
}


# Install AS3



# Create CTS VM
resource "azurerm_public_ip" "cts_vm" {
  name                = "ctsVmPip"
  resource_group_name = azurerm_resource_group.cts.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cts_vm" {
  name                = "ctsVmNic"
  location            = var.location
  resource_group_name = azurerm_resource_group.cts.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.cts_vm.id
  }
}

resource "azurerm_linux_virtual_machine" "cts_vm" {
  name                = "ctsVm"
  location            = var.location
  resource_group_name = azurerm_resource_group.cts.name
  size                = "Standard_D2as_v4"
  admin_username      = "azureuser"
  computer_name       = local.cts_hostname
  network_interface_ids = [
    azurerm_network_interface.cts_vm.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.boundary.public_key_openssh
  }

  # Using Standard SSD tier storage
  # Accepting the standard disk size from image
  # No data disk is being used
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  #Source image is hardcoded b/c I said so
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  #Custom data from the boundary.tmpl file
  custom_data = base64encode(
      templatefile("${path.module}/CTS.tpl", {
          big_ip_address = module.bigip.private_ip_address
          big_ip_password = var.big_ip_password
      })
  )
}


# NSGs

resource "azurerm_network_security_group" "cts" {
  name                = "ctsNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.cts.name
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
  resource_group_name         = azurerm_resource_group.cts.name
  network_security_group_name = azurerm_network_security_group.cts.name
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
  resource_group_name         = azurerm_resource_group.cts.name
  network_security_group_name = azurerm_network_security_group.cts.name
}

resource "azurerm_network_security_rule" "consul" {
  name                        = "consul"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8500"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.cts.name
  network_security_group_name = azurerm_network_security_group.cts.name
}

resource "azurerm_network_interface_security_group_association" "bigip" {
  network_interface_id      = azurerm_network_interface.cts_vm.id
  network_security_group_id = azurerm_network_security_group.cts.id
}

output "cts_public_ip_address" {
  value = azurerm_public_ip.cts_vm.ip_address
}

output "bigip_public_ip_address" {
  value = module.bigip.public_ip_address
}