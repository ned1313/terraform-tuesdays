provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "for-example"
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

  nat_subnets = { for name, subnet in local.subnet_by_name : name => subnet if subnet.nat }

  nat_subnet_ids = [for k, v in local.nat_subnets : azurerm_subnet.example["${k}"].id]

}

resource "azurerm_virtual_network" "example" {
  name                = "for-example-network"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  for_each             = local.subnet_by_name
  name                 = each.key
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_public_ip" "example" {
  name                = "natgw-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "example" {
  name                = "natgw-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "Standard"

}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.example.id
  public_ip_address_id = azurerm_public_ip.example.id
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  for_each       = toset(local.nat_subnet_ids)
  subnet_id      = each.key
  nat_gateway_id = azurerm_nat_gateway.example.id
}