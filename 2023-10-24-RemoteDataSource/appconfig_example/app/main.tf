# Configure the Azure provider
provider "azurerm" {
  features {}
}

variable "app_config_store_id" {
  type        = string
  description = "ID of the App Configuration store."
}

# Get the App Subnet ID from App Config
data "azurerm_app_configuration_key" "app_subnet_id" {
  configuration_store_id = var.app_config_store_id
  key                    = "app_subnet_id"
  label                  = azurerm_resource_group.tacocat.location
}

# Create a resource group
resource "azurerm_resource_group" "tacocat" {
  name     = "tacocat2-resource-group"
  location = "eastus"
}

# Create a network interface
resource "azurerm_network_interface" "tacocat" {
  name                = "tacocat-nic"
  location            = azurerm_resource_group.tacocat.location
  resource_group_name = azurerm_resource_group.tacocat.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_app_configuration_key.app_subnet_id.value
    private_ip_address_allocation = "Dynamic"
  }
}
