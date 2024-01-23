provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "main" {
  name = "${terraform.workspace}-storage-test"
  location = "eastus"
}