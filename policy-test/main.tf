provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "policy-as-code-test"
  location = "eastus"

  tags = {
    owner       = "Zaphod"
    environment = "development"
    costcenter  = "8675309"
  }
}