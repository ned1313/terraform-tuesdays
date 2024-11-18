provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "training" {
  name     = "for-expression"
  location = "East US"
}

locals {
  subnets = [
    {
      name           = "subnet1"
      address_prefix = "10.0.0.0/24"
      nat            = false
    },
    {
      name           = "subnet2"
      address_prefix = "10.0.1.0/24"
      nat            = true
    },
    {
      name           = "subnet3"
      address_prefix = "10.0.2.0/24"
      nat            = true
    }
  ]

  subnet_by_name = { for subnet in local.subnets : subnet.name => subnet }

  nat_subnets = [ for name, subnet in local.subnet_by_name : name if subnet.nat ]

}

resource "azurerm_virtual_network" "training" {
  name                = "for-expression-network"
  location            = azurerm_resource_group.training.location
  resource_group_name = azurerm_resource_group.training.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "training" {
  for_each             = local.subnet_by_name
  name                 = each.key
  resource_group_name  = azurerm_resource_group.training.name
  virtual_network_name = azurerm_virtual_network.training.name
  address_prefixes     = [each.value.address_prefix]

}

resource "azurerm_public_ip" "training" {
  name                = "natgw-public-ip"
  location            = azurerm_resource_group.training.location
  resource_group_name = azurerm_resource_group.training.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "training" {
  name                = "natgw-training"
  resource_group_name = azurerm_resource_group.training.name
  location            = azurerm_resource_group.training.location
  sku_name            = "Standard"

}

resource "azurerm_nat_gateway_public_ip_association" "training" {
  nat_gateway_id       = azurerm_nat_gateway.training.id
  public_ip_address_id = azurerm_public_ip.training.id
}

resource "azurerm_subnet_nat_gateway_association" "training" {
  for_each       = toset(local.nat_subnets)
  subnet_id      = azurerm_subnet.training[each.key].id
  nat_gateway_id = azurerm_nat_gateway.training.id
}

output "subnet_ids" {
  value = [ for subnet in azurerm_subnet.training : subnet.id ]
}