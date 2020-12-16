#############################################################################
# VARIABLES
#############################################################################

variable "location" {
  type    = string
  default = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "mysql"
}

locals {
  resource_group_name  = "${var.naming_prefix}${random_integer.sa_num.result}"
}

##################################################################################
# RESOURCES
##################################################################################
resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "setup" {
  name     = local.resource_group_name
  location = var.location
}