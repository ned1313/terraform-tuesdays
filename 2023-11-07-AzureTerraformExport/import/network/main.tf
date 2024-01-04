resource "azurerm_virtual_network" "res-0" {
  address_space       = ["10.42.0.0/16"]
  location            = "eastus"
  name                = "tacotruck"
  resource_group_name = "tacotruck-network"
  tags = {
    ENV = "test"
  }
}
resource "azurerm_subnet" "res-1" {
  address_prefixes     = ["10.42.1.0/24"]
  name                 = "app"
  resource_group_name  = "tacotruck-network"
  virtual_network_name = "tacotruck"
  depends_on = [
    azurerm_virtual_network.res-0,
  ]
}
resource "azurerm_subnet" "res-2" {
  address_prefixes     = ["10.42.2.0/24"]
  name                 = "data"
  resource_group_name  = "tacotruck-network"
  virtual_network_name = "tacotruck"
  depends_on = [
    azurerm_virtual_network.res-0,
  ]
}
resource "azurerm_subnet" "res-3" {
  address_prefixes     = ["10.42.0.0/24"]
  name                 = "web"
  resource_group_name  = "tacotruck-network"
  virtual_network_name = "tacotruck"
  depends_on = [
    azurerm_virtual_network.res-0,
  ]
}
