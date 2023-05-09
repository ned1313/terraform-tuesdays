module "web_app" {
  source = "./modules/web_tier/"
  name = "web-app-a"
  size = "medium"
  min_count = 2
}

locals {
    web_app_address = module.web_app.app_dns_address
}

module "primary_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
}

module "sp" {
    source = "../create-azure-sp"
}

module "my_vm" {
    source = "./modules/azure_vm"
    resource_group_name = "my-rg"
    region = "westus"
}