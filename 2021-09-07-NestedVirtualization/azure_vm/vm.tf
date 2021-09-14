resource "tls_private_key" "hypervisor" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  content  = tls_private_key.hypervisor.private_key_pem
  filename = "${path.root}/azure_vms_private_key.pem"
}

resource "azurerm_availability_set" "hypervisor" {
  name                         = local.hypervisor_vm
  location                     = azurerm_resource_group.vnet.location
  resource_group_name          = azurerm_resource_group.vnet.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "hypervisor" {
  name                = "${local.hypervisor_vm}-primary"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  sku                 = "Basic"
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.hypervisor_vm}-primary"
}

resource "azurerm_public_ip" "nested" {
  name                = "${local.hypervisor_vm}-nested"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  sku                 = "Basic"
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.hypervisor_vm}-nested"
}

resource "azurerm_network_interface" "hypervisor" {
  name                = local.hypervisor_vm
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hypervisor.id
    primary                       = true
  }

  ip_configuration {
    name                          = "nested"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nested.id

  }
}

resource "azurerm_network_interface_security_group_association" "hypervisor" {
  network_interface_id      = azurerm_network_interface.hypervisor.id
  network_security_group_id = azurerm_network_security_group.hypervisor_nics.id
}

resource "azurerm_linux_virtual_machine" "hypervisor" {
  name                = local.hypervisor_vm
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  size                = var.hypervisor_vm_size
  admin_username      = "azureuser"
  computer_name       = local.hypervisor_vm
  availability_set_id = azurerm_availability_set.hypervisor.id
  network_interface_ids = [
    azurerm_network_interface.hypervisor.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.hypervisor.public_key_openssh
  }

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

  custom_data = filebase64("${path.module}/setup.tpl")
}

resource "azurerm_managed_disk" "hypervisor" {
  name                 = "${local.hypervisor_vm}-vms"
  location             = azurerm_resource_group.vnet.location
  resource_group_name  = azurerm_resource_group.vnet.name
  storage_account_type = var.data_disk_storage_class
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "hypervisor" {
  managed_disk_id    = azurerm_managed_disk.hypervisor.id
  virtual_machine_id = azurerm_linux_virtual_machine.hypervisor.id
  lun                = "3"
  caching            = "ReadWrite"
}