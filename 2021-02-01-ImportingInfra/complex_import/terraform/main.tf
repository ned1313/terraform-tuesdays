# We need to create all the same resources we have from the ARM template
# Here's the list
# 1 - virtual network
# 2 - two subnets in the vnet
# 3 - two NICs
# 4 - two NSGs (first NSG allows RDP from anywhere)
# 5 - one storage account for diagnostics
# 6 - one public IP address
# 7 - one virtual machine with just the OS disk

# Start with the terraform block and provider block
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.41.0"
        }
    }
}

provider "azurerm" {
    features {}
}

# We're going to need variables that align to the template
variable "location" {
  default = "eastus"
}

variable "prefix" {
  default = "tacos"
}

variable "id" {
    type = string
    description = "You'll need this value from the deployment script"
}

variable "adminUsername" {
  default = "azureadmin"
}

variable "adminPassword" {
  type = string
  description = "Whatever value you used in the parameters script"
  sensitive = true
}

variable "diagStorageAccountName" {
  type = string
  description = "Name of diagnostic storage account from template"
}

# Let's construct the other values

locals {
  resource_group_name = "${var.prefix}-${var.id}"
  virtualMachineSize = "Standard_DS1_v2"
  virtualMachineName = "VM-MultiNic"
  nic1 = "nic-1"
  nic2 = "nic-2"
  virtualNetworkName = "virtualNetwork"
  subnet1Name = "subnet-1"
  subnet2Name = "subnet-2"
  virtualNetworkAddressSpace = "10.0.0.0/16"
  subnet1AddressSpace = "10.0.0.0/24"
  subnet2AddressSpace = "10.0.1.0/24"
  publicIPAddressName = "publicIp"
  networkSecurityGroupName = "NSG"
  networkSecurityGroupName2 = "${local.subnet2Name}-nsg"
}

# Now the resource group

resource "azurerm_resource_group" "tacos" {
    name = local.resource_group_name
    location = var.location
}

# Vnet configuration
resource "azurerm_virtual_network" "vnet" {
  name = local.virtualNetworkName
  location = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name

  address_space = [local.virtualNetworkAddressSpace]

  subnet {
    address_prefix = local.subnet1AddressSpace
    name = local.subnet1Name
  }

  subnet {
    address_prefix = local.subnet2AddressSpace
    name = local.subnet2Name
    security_group = TBD
  }
}

resource "azurerm_subnet" "subnet1" {
  name = local.subnet1Name
  resource_group_name  = azurerm_resource_group.tacos.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet1AddressSpace]
}

resource "azurerm_subnet" "subnet2" {
  name = local.subnet2Name
  resource_group_name  = azurerm_resource_group.tacos.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet2AddressSpace]
  
}

# Network security groups
resource "azurerm_network_security_group" "NSG" {
  name                = local.networkSecurityGroupName
  location            = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "NSG2" {
  name                = local.networkSecurityGroupName2
  location            = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name
}

resource "azurerm_subnet_network_security_group_association" "NSG2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.NSG2.id
}

resource "azurerm_network_interface_security_group_association" "nic1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

# Public IP Address
resource "azurerm_public_ip" "pip" {
  name                = local.publicIPAddressName
  resource_group_name = azurerm_resource_group.tacos.name
  location            = azurerm_resource_group.tacos.location
  allocation_method   = "Dynamic"

}

# Virtual NICs
resource "azurerm_network_interface" "nic1" {
  name                = local.nic1
  location            = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = local.nic2
  location            = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Diagnostics storage account
resource "azurerm_storage_account" "VMDiag" {
  name = var.diagStorageAccountName
  location            = azurerm_resource_group.tacos.location
  resource_group_name = azurerm_resource_group.tacos.name
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "LRS"

}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "VM" {
  name                = local.virtualMachineName
  resource_group_name = azurerm_resource_group.tacos.name
  location            = azurerm_resource_group.tacos.location
  size                = local.virtualMachineSize
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
    azurerm_network_interface.nic2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.VMDiag.primary_blob_endpoint
  }
}

