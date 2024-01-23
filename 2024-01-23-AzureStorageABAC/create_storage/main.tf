provider "azurerm" {
  features {}
  # Set storage access to use Azure AD instead of storage key SAS
  storage_use_azuread = true
}

data "azurerm_subscription" "main" {}

# Use random string to create naming suffix
resource "random_string" "main" {
  length  = 6
  special = false
  upper   = false
}

locals {
  naming_string = "abac${random_string.main.result}"
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = local.naming_string
  location = "eastus"
}

# Create storage account
resource "azurerm_storage_account" "main" {
  name                = local.naming_string
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = "GRS"
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = false


  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 90
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }

  }

  sas_policy {
    expiration_period = "00.02:00:00"
    expiration_action = "Log"
  }

}


# Create a container in storage account
resource "azurerm_storage_container" "main" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "nope" {
  name                  = "tfnope"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}


# Create a custom role with ABAC
resource "azurerm_role_definition" "main" {
  name        = "${local.naming_string}-write-access"
  scope       = data.azurerm_subscription.main.id
  description = "Custom role definition allowing write access to the storage account ${azurerm_storage_account.main.name}."

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
    ]
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.main.id
  ]
}

# Create a service principal to assign role to
data "azuread_client_config" "current" {}

resource "azuread_application" "main" {
  display_name = local.naming_string
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "main" {
  client_id                    = azuread_application.main.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.id
}

resource "azurerm_role_assignment" "main" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = azurerm_role_definition.main.name
  principal_id         = azuread_service_principal.main.object_id

  condition = templatefile("${path.module}/condition.tpl", {
    container_name = azurerm_storage_container.main.name
    state_path     = "tacowagon"
  })

  condition_version                = "2.0"
  skip_service_principal_aad_check = true

  depends_on = [ azurerm_role_definition.main ]
}

# Output should include storage account name and role name

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_name" {
  value = azurerm_storage_container.main.name
}

output "role_name" {
  value = azurerm_role_definition.main.name
}

output "service_principal" {
  value = azuread_service_principal.main
}

output "subscription_id" {
  value = data.azurerm_subscription.main.subscription_id
}

output "service_principal_password" {
  value = nonsensitive(azuread_service_principal_password.main.value)
}