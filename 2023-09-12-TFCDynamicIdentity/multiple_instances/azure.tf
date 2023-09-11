# Providers
provider "azurerm" {
  features {

  }
}

provider "azuread" {

}

# Create the necessary resources for the Dynamic Identity
# Create two applications
resource "azuread_application" "default" {
  display_name = "${var.az_identity_name}-default"
}

resource "azuread_application" "security" {
  display_name = "${var.az_identity_name}-security"
}

# Create a federated identity credential for plan and apply

resource "azuread_application_federated_identity_credential" "default" {
  for_each              = toset(["plan", "apply"])
  application_object_id = azuread_application.default.object_id
  display_name          = "${azuread_application.default.display_name}-${each.key}"
  description           = "Default Terraform Cloud credential to run ${each.key} phase on ${var.tfc_organization_name}/${var.tfc_project_name}/${var.tfc_workspace_name}."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:${each.key}"
}

resource "azuread_application_federated_identity_credential" "security" {
  for_each              = toset(["plan", "apply"])
  application_object_id = azuread_application.security.object_id
  display_name          = "${azuread_application.security.display_name}-${each.key}"
  description           = "Security Terraform Cloud credential to run ${each.key} phase on ${var.tfc_organization_name}/${var.tfc_project_name}/${var.tfc_workspace_name}."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:${each.key}"
}

# Create a service principal
data "azuread_client_config" "current" {}

locals {
  owner_id = var.az_owner_id != null ? var.az_owner_id : data.azuread_client_config.current.object_id
}

resource "azuread_service_principal" "default" {
  application_id = azuread_application.default.application_id
  owners         = [local.owner_id]
}

resource "azuread_service_principal" "security" {
  application_id = azuread_application.security.application_id
  owners         = [local.owner_id]
}

# Grant the service principal Contributor permissions on the subscription
data "azurerm_subscription" "current" {}

locals {
  subscription_id = var.az_subscription_id != null ? var.az_subscription_id : data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "default" {
  scope                = local.subscription_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.default.object_id
}

resource "azurerm_role_assignment" "security" {
  scope                = local.subscription_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.security.object_id
}