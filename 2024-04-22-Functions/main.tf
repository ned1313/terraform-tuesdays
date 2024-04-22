provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "rg" {
  name     = "function-example"
  location = "East US"
}

locals {
  subnets = {
    subnet1 = "10.0.0.0/24"
    subnet2 = "10.0.1.0/24"
  }
  environment = "dev"
}

module "vnet" {
  source = "Azure/vnet/azurerm"
    version = "4.1.0"
    resource_group_name = azurerm_resource_group.rg.name
    vnet_location            = azurerm_resource_group.rg.location
    vnet_name                = "${local.environment}-vnet"
    address_space = ["10.0.0.0/16"]
    use_for_each = true

    subnet_names = ???
    subnet_prefixes = ???
}
