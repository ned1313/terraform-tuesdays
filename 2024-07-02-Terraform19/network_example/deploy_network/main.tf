terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.0"
        }
    }

}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "nettest" {
    name     = "nettest-resource-group"
    location = "West US"
}

resource "azurerm_virtual_network" "nettest" {
    name                = "nettest-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.nettest.location
    resource_group_name = azurerm_resource_group.nettest.name
}

resource "azurerm_subnet" "web" {
    name                 = "web"
    resource_group_name  = azurerm_resource_group.nettest.name
    virtual_network_name = azurerm_virtual_network.nettest.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
    name                 = "app"
    resource_group_name  = azurerm_resource_group.nettest.name
    virtual_network_name = azurerm_virtual_network.nettest.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
    name                 = "db"
    resource_group_name  = azurerm_resource_group.nettest.name
    virtual_network_name = azurerm_virtual_network.nettest.name
    address_prefixes     = ["10.0.3.0/24"]
}