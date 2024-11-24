provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

}

module "network" {
  source = "../../modules/network"

  location    = var.location
  prefix      = var.prefix
  common_tags = var.common_tags
  cidr_block  = var.cidr_block
  subnets     = var.subnets
}