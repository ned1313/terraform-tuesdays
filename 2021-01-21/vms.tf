# Generate key pair for all VMs
resource "tls_private_key" "cka" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  content  = tls_private_key.cka.private_key_pem
  filename = "${path.root}/azure_vms_private_key.pem"
}

##################### CONTROLLER VM RESOURCES ###################################
resource "azurerm_availability_set" "controller" {
  name                         = local.controller_vm
  location                     = var.location
  resource_group_name          = azurerm_resource_group.cka.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "controller" {
    count               = var.controller_vm_count
    name = "controllerPublicIP-${count.index}"
    resource_group_name = azurerm_resource_group.cka.name
    location = var.location
    allocation_method = "Static"
    sku = "Standard"
}


resource "azurerm_network_interface" "controller" {
  count               = var.controller_vm_count
  name                = "${local.controller_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.controller[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "controller" {
  count                     = var.controller_vm_count
  network_interface_id      = azurerm_network_interface.controller[count.index].id
  network_security_group_id = azurerm_network_security_group.controller_nics.id
}

resource "azurerm_linux_virtual_machine" "controller" {
  count               = var.controller_vm_count
  name                = "${local.controller_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name
  size                = var.controller_vm_size
  admin_username      = "azureuser"
  computer_name       = "controller-${count.index}"
  availability_set_id = azurerm_availability_set.controller.id
  network_interface_ids = [
    azurerm_network_interface.controller[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.cka.public_key_openssh
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

}

##################### WORKER VM RESOURCES ###################################

resource "azurerm_network_interface" "worker" {
  count               = var.worker_vm_count
  name                = "${local.worker_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "worker" {
  count                     = var.worker_vm_count
  network_interface_id      = azurerm_network_interface.worker[count.index].id
  network_security_group_id = azurerm_network_security_group.worker_nics.id
}

resource "azurerm_linux_virtual_machine" "worker" {
  count               = var.worker_vm_count
  name                = "${local.worker_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.cka.name
  size                = var.worker_vm_size
  admin_username      = "azureuser"
  computer_name       = "worker-${count.index}"
  availability_set_id = azurerm_availability_set.controller.id
  network_interface_ids = [
    azurerm_network_interface.worker[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.cka.public_key_openssh
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

}