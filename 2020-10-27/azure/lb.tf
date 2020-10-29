resource "azurerm_public_ip" "boundary" {
  name                = local.pip_name
  resource_group_name = azurerm_resource_group.boundary.name
  location            = azurerm_resource_group.boundary.location
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "boundary" {
  name                = local.lb_name
  location            = azurerm_resource_group.boundary.location
  resource_group_name = azurerm_resource_group.boundary.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.boundary.id
  }
}

resource "azurerm_lb_backend_address_pool" "pools" {
  for_each = toset(["controller","worker"])
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = each.key
}

resource "azurerm_network_interface_backend_address_pool_association" "controller" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["controller"].id
  ip_configuration_name   = "primary"
  network_interface_id    = azurerm_network_interface.controller[count.index].id
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["worker"].id
  ip_configuration_name   = "primary"
  network_interface_id    = azurerm_network_interface.worker[count.index].id
}