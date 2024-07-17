provider "azurerm" {
  features {}
  
}

resource "azurerm_resource_group" "test" {
  name = "terrahash-test"
  location = "East US"
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"
  
    resource_group_name = azurerm_resource_group.test.name
    use_for_each = true
    vnet_location = azurerm_resource_group.test.location

}



module "internal" {
    source = "./modules/server"
}

module "label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.25.0"
  enabled = false
  environment = "dev"
  name = "taco"
  stage = "dev"
  namespace = "nc"
}