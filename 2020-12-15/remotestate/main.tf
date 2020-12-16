###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"

    }
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "location" {
  type    = string
  default = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "tacos"
}

locals {
  resource_group_name  = "${var.naming_prefix}${random_integer.sa_num.result}"
  storage_account_name = "${lower(var.naming_prefix)}${random_integer.sa_num.result}"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  features {}
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

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name

}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "17520h")

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

#############################################################################
# PROVISIONERS
#############################################################################

resource "local_file" "post-config" {
    filename = "${path.module}/backend-config.txt"
    content = <<EOT
storage_account_name = "${azurerm_storage_account.sa.name}"
container_name = "terraform-state"
key = "terraform.tfstate"
sas_token = "${data.azurerm_storage_account_sas.state.sas}"
EOT
     depends_on = [azurerm_storage_container.ct]
}

##################################################################################
# OUTPUT
##################################################################################

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}