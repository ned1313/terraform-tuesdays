resource "azurerm_public_ip" "boundary" {
  name                = local.pip_name
  resource_group_name = azurerm_resource_group.boundary.name
  location            = azurerm_resource_group.boundary.location
  allocation_method   = "Static"
  domain_name_label = lower(azurerm_resource_group.boundary.name)
  sku = "Standard"
}

resource "azurerm_lb" "boundary" {
  name                = local.lb_name
  location            = azurerm_resource_group.boundary.location
  resource_group_name = azurerm_resource_group.boundary.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.boundary.id
  }
}

resource "azurerm_lb_backend_address_pool" "pools" {
  for_each            = toset(["controller", "worker"])
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = each.key
}

resource "azurerm_network_interface_backend_address_pool_association" "controller" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["controller"].id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.controller[count.index].id
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["worker"].id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.worker[count.index].id
}

resource "azurerm_lb_probe" "controller_9200" {
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = "port-9200"
  port                = 9200
}

resource "azurerm_lb_probe" "worker_9202" {
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = "port-9202"
  port                = 9202
}

resource "azurerm_lb_rule" "controller" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "Controller"
  protocol                       = "Tcp"
  frontend_port                  = 9200
  backend_port                   = 9200
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id = azurerm_lb_probe.controller_9200.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["controller"].id
}

resource "azurerm_lb_rule" "worker" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "Worker"
  protocol                       = "Tcp"
  frontend_port                  = 9202
  backend_port                   = 9202
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id = azurerm_lb_probe.worker_9202.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["worker"].id
}

