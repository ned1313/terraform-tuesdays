provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias = "westeurope"
}

resource "azurerm_resource_group" "main" {
  name     = "terraform-azure-basic"
  location = "West Europe"
}

variable "vm_name" {
  type = string
  default = "terraform-azure-basic"
}

module "compute" {
  source = "./compute"
  providers = {
    azurerm = azurerm.westeurope
  }

  computer_name = var.vm_name
}

output "private_ip" {
  value = module.compute.private_ip
}