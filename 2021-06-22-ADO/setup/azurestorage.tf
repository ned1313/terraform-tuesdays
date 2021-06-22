provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "setup" {
  name     = local.az_resource_group_name
  location = var.az_location
}

resource "azurerm_storage_account" "sa" {
  name                     = local.az_storage_account_name
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.az_location
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