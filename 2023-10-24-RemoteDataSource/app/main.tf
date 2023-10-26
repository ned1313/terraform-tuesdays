# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "tacocat" {
  name     = "tacocat-resource-group"
  location = "eastus"
}

# Create a network interface
resource "azurerm_network_interface" "tacocat" {
  name                = "tacocat-nic"
  location            = azurerm_resource_group.tacocat.location
  resource_group_name = azurerm_resource_group.tacocat.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the remote state data source
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}
