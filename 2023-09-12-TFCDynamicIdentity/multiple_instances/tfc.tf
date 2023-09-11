# Terraform Cloud Provider
provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.tfc_organization_name
}

# Create project
resource "tfe_project" "main" {
  name = var.tfc_project_name
}

# Create workspace
resource "tfe_workspace" "main" {
  name        = var.tfc_workspace_name
  project_id  = tfe_project.main.id
  description = "Test workspace for Multiple Dynamic Identities"
  auto_apply  = true
}

# Configure workspace variables
resource "tfe_variable" "azure_auth" {
  description  = "Enable Dynamic Identity for Azure"
  workspace_id = tfe_workspace.main.id
  key          = "TFC_AZURE_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
}

resource "tfe_variable" "client_id" {
  description  = "Default Azure Client ID for Dynamic Identity"
  workspace_id = tfe_workspace.main.id
  key          = "TFC_AZURE_RUN_CLIENT_ID"
  value        = azuread_application.default.application_id
  category     = "env"
}

resource "tfe_variable" "azure_auth_alias" {
  description  = "Enable Aliased Dynamic Identity for Azure"
  workspace_id = tfe_workspace.main.id
  key          = "TFC_AZURE_PROVIDER_AUTH_${var.az_alias}"
  value        = "true"
  category     = "env"
}

resource "tfe_variable" "client_id_alias" {
  description  = "Aliased Azure Client ID for Dynamic Identity"
  workspace_id = tfe_workspace.main.id
  key          = "TFC_AZURE_RUN_CLIENT_ID_${var.az_alias}"
  value        = azuread_application.security.application_id
  category     = "env"
}

resource "tfe_variable" "tenant_id" {
  description  = "Default Azure Tenant ID for Dynamic Identity"
  workspace_id = tfe_workspace.main.id
  key          = "ARM_TENANT_ID"
  value        = data.azurerm_subscription.current.tenant_id
  category     = "env"
}

resource "tfe_variable" "subscription_id" {
  description  = "Default Azure Subscription ID for Dynamic Identity"
  workspace_id = tfe_workspace.main.id
  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.azurerm_subscription.current.subscription_id
  category     = "env"
}