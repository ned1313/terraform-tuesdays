locals {
  vnet_info = {
    name    = "${local.prefix}-vnet"
    address = "10.0.0.0/16"
  }
  subnets = [
    {
      name    = "app"
      address = "10.0.0.0/24"
    },
    {
      name    = "web"
      address = "10.0.1.0/24"
    },
    {
      name    = "db"
      address = "10.0.2.0/24"
    }
  ]
}

resource "azurerm_resource_group" "vnet" {
  name     = local.prefix
  location = var.region
}


module "network" {
  source              = "Azure/network/azurerm"
  version             = "~> 3.0"
  resource_group_name = azurerm_resource_group.vnet.name
  vnet_name           = local.vnet_info.name
  address_space       = local.vnet_info.address
  subnet_prefixes     = local.subnets.*.address
  subnet_names        = local.subnets.*.name

  depends_on = [azurerm_resource_group.vnet]
}