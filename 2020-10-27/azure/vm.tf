# Generate key pair for all VMs
resource "tls_private_key" "boundary" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  content  = tls_private_key.boundary.private_key_pem
  filename = "${path.root}/azure_vms_private_key.pem"
}

# Create User Identities for Controller VMs and Worker VMs
resource "azurerm_user_assigned_identity" "controller" {
  resource_group_name = azurerm_resource_group.boundary.name
  location            = var.location

  name = local.controller_user_id
}

resource "azurerm_user_assigned_identity" "worker" {
  resource_group_name = azurerm_resource_group.boundary.name
  location            = var.location

  name = local.worker_user_id
}

##################### CONTROLLER VM RESOURCES ###################################
resource "azurerm_availability_set" "controller" {
  name                         = local.controller_vm
  location                     = var.location
  resource_group_name          = azurerm_resource_group.boundary.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_network_interface" "controller" {
  count               = var.controller_vm_count
  name                = "${local.controller_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "controller" {
  count                     = var.controller_vm_count
  network_interface_id      = azurerm_network_interface.controller[count.index].id
  network_security_group_id = azurerm_network_security_group.controller_nics.id
}

resource "azurerm_network_interface_application_security_group_association" "controller" {
  count                         = var.controller_vm_count
  network_interface_id          = azurerm_network_interface.controller[count.index].id
  application_security_group_id = azurerm_application_security_group.controller_asg.id
}

data "template_file" "controller" {
  template = file("${path.module}/boundary.tmpl")

  vars = {
    vault_name  = local.vault_name
    type = "controller"
    name = "boundary"
    tenant_id   = data.azurerm_client_config.current.tenant_id
    db_username = var.db_username
    db_password = var.db_password
    db_endpoint = azurerm_postgresql_server.boundary.fqdn
    db_name = local.pg_name
    public_ip    = azurerm_public_ip.boundary.ip_address
    controller_ips = join(",",azurerm_network_interface.controller[*].private_ip_address)
  }
}

resource "azurerm_linux_virtual_machine" "controller" {
  count               = var.controller_vm_count
  name                = "${local.controller_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
  size                = var.controller_vm_size
  admin_username      = "azureuser"
  computer_name       = "controller-${count.index}"
  availability_set_id = azurerm_availability_set.controller.id
  network_interface_ids = [
    azurerm_network_interface.controller[count.index].id,
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.controller.id]
  }

  secret {
    key_vault_id = azurerm_key_vault.boundary.id

    certificate {
      url = azurerm_key_vault_certificate.boundary.secret_id
    }
  }

  custom_data = base64encode(data.template_file.controller.rendered)
}

##################### WORKER VM RESOURCES ###################################

resource "azurerm_network_interface" "worker" {
  count               = var.worker_vm_count
  name                = "${local.worker_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "worker" {
  count                     = var.worker_vm_count
  network_interface_id      = azurerm_network_interface.worker[count.index].id
  network_security_group_id = azurerm_network_security_group.worker_nics.id
}

resource "azurerm_network_interface_application_security_group_association" "worker" {
  count                         = var.worker_vm_count
  network_interface_id          = azurerm_network_interface.worker[count.index].id
  application_security_group_id = azurerm_application_security_group.worker_asg.id
}

data "template_file" "worker" {
  template = file("${path.module}/boundary.tmpl")

  vars = {
    vault_name     = local.vault_name
    type           = "worker"
    name = "boundary"
    tenant_id      = data.azurerm_client_config.current.tenant_id
    public_ip    = azurerm_public_ip.boundary.ip_address
    controller_ips = join(",",azurerm_network_interface.controller[*].private_ip_address)
    db_username = var.db_username
    db_password = var.db_password
    db_name = local.pg_name
    db_endpoint = azurerm_postgresql_server.boundary.fqdn
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  count               = var.worker_vm_count
  name                = "${local.worker_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
  size                = var.worker_vm_size
  admin_username      = "azureuser"
  computer_name       = "worker-${count.index}"
  availability_set_id = azurerm_availability_set.controller.id
  network_interface_ids = [
    azurerm_network_interface.worker[count.index].id,
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.worker.id]
  }

  secret {
    key_vault_id = azurerm_key_vault.boundary.id

    certificate {
      url = azurerm_key_vault_certificate.boundary.secret_id
    }
  }

  custom_data = base64encode(data.template_file.worker.rendered)

  depends_on = [azurerm_linux_virtual_machine.controller]
}