# Create an application
resource "azuread_application" "oidc" {
  display_name = var.identity_name
}

# Create a federated identity
locals {
  ref_string     = var.entity_type == "ref" && var.ref_branch != null ? "refs/head/${var.ref_branch}" : var.entity_type == "ref" && var.ref_tag != null ? "refs/tags/${var.ref_tag}" : null
  subject_string = var.entity_type == "environment" ? "environment:${var.environment_name}" : var.entity_type == "ref" ? "ref:${local.ref_string}" : "pull-request"
}

resource "azuread_application_federated_identity_credential" "oidc" {
  application_object_id = azuread_application.oidc.object_id
  display_name          = azuread_application.oidc.display_name
  description           = "GitHub OIDC for ${var.repository_name}."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.repository_name}:${local.subject_string}"
}

# Create a service principal
data "azuread_client_config" "current" {}

locals {
  owner_id = var.owner_id != null ? var.owner_id : data.azuread_client_config.current.object_id
}

resource "azuread_service_principal" "oidc" {
  application_id = azuread_application.oidc.application_id
  owners         = [local.owner_id]
}