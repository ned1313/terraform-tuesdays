# Configure the Azure provider
provider "azurerm" {
  features {}
}

variable "app_config_store_id" {
  type        = string
  description = "ID of the App Configuration store."
}

# Create a resource group
resource "azurerm_resource_group" "shared" {
  name     = "shared2-resource-group"
  location = "eastus"
}

# Get the CIDR range from App Config
data "azurerm_app_configuration_key" "shared_vnet" {
  configuration_store_id = var.app_config_store_id
  key                    = "shared_vnet"
  label                  = azurerm_resource_group.shared.location
}

# Get the subnet range from AppConfig
data "azurerm_app_configuration_key" "app_subnet" {
  configuration_store_id = var.app_config_store_id
  key                    = "app_subnet"
  label                  = azurerm_resource_group.shared.location
}

# Create a virtual network
resource "azurerm_virtual_network" "shared" {
  name                = "shared-vnet"
  address_space       = [data.azurerm_app_configuration_key.shared_vnet.value]
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
}

# Create a subnet
resource "azurerm_subnet" "shared" {
  name                 = "app-subnet"
  address_prefixes     = [data.azurerm_app_configuration_key.app_subnet.value]
  virtual_network_name = azurerm_virtual_network.shared.name
  resource_group_name  = azurerm_resource_group.shared.name
}

# Add the subnet ID to App Config
resource "azurerm_app_configuration_key" "app_subnet_id" {
  configuration_store_id = var.app_config_store_id
  key                    = "app_subnet_id"
  label                  = "eastus"
  value                  = azurerm_subnet.shared.id
}
