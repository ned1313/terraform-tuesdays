# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkSecurityGroups/SecGroupNet"
resource "azurerm_network_security_group" "main" {
  location            = "eastus"
  name                = "SecGroupNet"
  resource_group_name = "tacoTruck"
  security_rule = [{
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "22"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "SSH"
    priority                                   = 1000
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
  tags = {}
}

# __generated__ by Terraform from "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt"
resource "azurerm_network_interface" "main" {
  dns_servers                   = []
  edge_zone                     = null
  enable_accelerated_networking = false
  enable_ip_forwarding          = false
  internal_dns_name_label       = null
  location                      = "eastus"
  name                          = "tacoVMNetInt"
  resource_group_name           = "tacoTruck"
  tags                          = {}
  ip_configuration {
    gateway_load_balancer_frontend_ip_configuration_id = null
    name                                               = "ipconfig1"
    primary                                            = true
    private_ip_address                                 = "10.42.0.4"
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = "IPv4"
    public_ip_address_id                               = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/publicIPAddresses/tacoVMPublicIP"
    subnet_id                                          = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/virtualNetworks/tacoNet/subnets/Subnet"
  }
}

# __generated__ by Terraform
resource "azurerm_subnet" "main" {
  address_prefixes                              = ["10.42.0.0/24"]
  name                                          = "Subnet"
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
  resource_group_name                           = "tacoTruck"
  #service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  virtual_network_name                          = "tacoNet"
}

# __generated__ by Terraform from "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt|/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkSecurityGroups/SecGroupNet"
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt"
  network_security_group_id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkSecurityGroups/SecGroupNet"
}

# __generated__ by Terraform
resource "azurerm_virtual_network" "main" {
  address_space           = ["10.42.0.0/16"]
  bgp_community           = null
  dns_servers             = []
  edge_zone               = null
  #flow_timeout_in_minutes = 0
  location                = "eastus"
  name                    = "tacoNet"
  resource_group_name     = "tacoTruck"
  tags = {}
}

# __generated__ by Terraform from "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/publicIPAddresses/tacoVMPublicIP"
resource "azurerm_public_ip" "main" {
  allocation_method       = "Dynamic"
  ddos_protection_mode    = "VirtualNetworkInherited"
  ddos_protection_plan_id = null
  domain_name_label       = "tacovm-et2nc7dxe3i4c"
  edge_zone               = null
  idle_timeout_in_minutes = 4
  ip_tags                 = {}
  ip_version              = "IPv4"
  location                = "eastus"
  name                    = "tacoVMPublicIP"
  public_ip_prefix_id     = null
  resource_group_name     = "tacoTruck"
  reverse_fqdn            = null
  sku                     = "Basic"
  sku_tier                = "Regional"
  tags                    = {}
  zones                   = []
}

# __generated__ by Terraform
resource "azurerm_linux_virtual_machine" "main" {
  admin_password                  = null # sensitive
  admin_username                  = "tacoAdmin"
  allow_extension_operations      = true
  availability_set_id             = null
  capacity_reservation_group_id   = null
  computer_name                   = "tacoVM"
  custom_data                     = null # sensitive
  dedicated_host_group_id         = null
  dedicated_host_id               = null
  disable_password_authentication = false
  edge_zone                       = null
  encryption_at_host_enabled      = false
  eviction_policy                 = null
  extensions_time_budget          = "PT1H30M"
  license_type                    = null
  location                        = "eastus"
  max_bid_price                   = -1
  name                            = "tacoVM"
  network_interface_ids           = ["/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/tacoTruck/providers/Microsoft.Network/networkInterfaces/tacoVMNetInt"]
  patch_assessment_mode           = "ImageDefault"
  patch_mode                      = "ImageDefault"
  #platform_fault_domain           = -1
  priority                        = "Regular"
  provision_vm_agent              = true
  proximity_placement_group_id    = null
  resource_group_name             = "tacoTruck"
  secure_boot_enabled             = false
  size                            = "Standard_D2s_v3"
  source_image_id                 = null
  tags                            = {}
  user_data                       = null
  virtual_machine_scale_set_id    = null
  vtpm_enabled                    = false
  zone                            = null
  os_disk {
    caching                          = "ReadWrite"
    disk_encryption_set_id           = null
    disk_size_gb                     = 30
    name                             = "tacoVM_disk1_73c80313eee44b5fb48437ce277c8340"
    secure_vm_disk_encryption_set_id = null
    security_encryption_type         = null
    storage_account_type             = "Standard_LRS"
    write_accelerator_enabled        = false
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
