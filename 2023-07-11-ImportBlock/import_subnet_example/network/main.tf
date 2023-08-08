resource "azurerm_virtual_network" "main" {
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  name                = var.vnet_name

  address_space = var.address_space
}

resource "azurerm_subnet" "main" {
  for_each             = var.subnets
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [each.value]
}