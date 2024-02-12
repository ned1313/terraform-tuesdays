provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "private-module-test"
  location = "eastus"
}

module "networking" {
  source  = "app.terraform.io/ned-in-the-cloud/networking/azurerm"
  version = "1.0.4"
  
  location = azurerm_resource_group.main.location
  name = azurerm_resource_group.main.name
  vnet_address_spacing = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.0.0/24"]
}

module "compute" {
  source  = "Azure/compute/azurerm"
  version = "5.3.0"
  
  resource_group_name = azurerm_resource_group.main.name
  vm_os_simple = "UbuntuServer"
  vnet_subnet_id = module.networking.subnet-ids[0]
  admin_username = "ZaphodBeeblebrox"
  admin_password = "P@ssword1234!!!"
  enable_ssh_key = false

  depends_on = [ azurerm_resource_group.main ]
}