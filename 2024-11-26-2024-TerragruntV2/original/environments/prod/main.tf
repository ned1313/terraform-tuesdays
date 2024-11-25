provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

}

# Add networking module
module "network" {
  source = "../../modules/network"

  location    = var.location
  prefix      = var.prefix
  common_tags = var.common_tags
  cidr_block  = var.cidr_block
  subnets     = var.subnets
}

# Add frontend module
module "frontend" {
  source = "../../modules/frontend"

  location    = var.location
  prefix      = var.prefix
  common_tags = var.common_tags
}

module "backend" {
  source = "../../modules/backend"

  location    = var.location
  prefix      = var.prefix
  common_tags = var.common_tags
  subnet_id   = module.network.subnet_id_map["backend"]
}

module "db" {
  source = "../../modules/db"

  location    = var.location
  prefix      = var.prefix
  common_tags = var.common_tags
  subnet_id   = module.network.subnet_id_map["db"]
}