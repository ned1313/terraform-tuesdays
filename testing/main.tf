provider "azurerm" {
  features {
    
  }
}

locals {
  web_subnet = "/asfoafihee"
}

import {
  to = azurerm_subnet.main
  id = local.web_subnet
}