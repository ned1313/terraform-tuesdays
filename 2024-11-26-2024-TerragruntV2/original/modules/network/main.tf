resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-network-rg"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  address_space       = [var.cidr_block]
  tags                = var.common_tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [each.value]
}