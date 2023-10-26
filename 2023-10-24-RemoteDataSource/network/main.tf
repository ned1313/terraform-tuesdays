# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "shared" {
  name     = "shared-resource-group"
  location = "eastus"
}

# Create a virtual network
resource "azurerm_virtual_network" "shared" {
  name                = "shared-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
}

# Create a subnet
resource "azurerm_subnet" "shared" {
  name                 = "shared-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.shared.name
  resource_group_name  = azurerm_resource_group.shared.name
}

output "resource_group_name" {
  value = azurerm_resource_group.shared.name
}

output "subnet_id" {
  value = azurerm_subnet.shared.id

}
