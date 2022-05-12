# We are going to create a service principal for the vault to use.

data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

locals {
  application_permissions = [
    "Application.Read.All",
    "Application.ReadWrite.All",
    "Application.ReadWrite.OwnedBy",
    "Directory.Read.All",
    "Directory.ReadWrite.All",
    "Group.Read.All",
    "Group.ReadWrite.All",
    "GroupMember.Read.All",
    "GroupMember.ReadWrite.All"
  ]
}

resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_application" "vault_tfc" {
  display_name = "vault-tfc"
  owners       = [data.azuread_client_config.current.object_id]

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    dynamic "resource_access" {
      for_each = toset(local.application_permissions)

      content {
        id   = azuread_service_principal.msgraph.app_role_ids[resource_access.value]
        type = "Role"
      }
    }
  }
}

resource "azuread_service_principal" "vault_tfc" {
  application_id = azuread_application.vault_tfc.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "vault_tfc" {
  service_principal_id = azuread_service_principal.vault_tfc.object_id
}

resource "azuread_app_role_assignment" "vault_tfc" {
  for_each            = toset(local.application_permissions)
  app_role_id         = azuread_service_principal.msgraph.app_role_ids[each.value]
  principal_object_id = azuread_service_principal.vault_tfc.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azurerm_role_assignment" "dev_subscription" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.vault_tfc.object_id
}

