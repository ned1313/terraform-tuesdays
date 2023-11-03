# Create Service Principals
data "azuread_client_config" "current" {}

# Create an application
resource "azuread_application" "oidc" {
  display_name = "branch-based-oidc"
}

resource "azuread_service_principal" "oidc" {
  application_id = azuread_application.oidc.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "oidc" {
  for_each              = toset(var.environments)
  application_object_id = azuread_application.oidc.object_id
  display_name          = "${azuread_application.oidc.display_name}-${each.value}"
  description           = "GitHub OIDC for ${var.repository_name} and branch ${each.value}."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.repository_name}:ref:refs/heads/${each.value}"
}

# add one for pull requests
resource "azuread_application_federated_identity_credential" "pr" {
  application_object_id = azuread_application.oidc.object_id
  display_name          = "${azuread_application.oidc.display_name}-pr"
  description           = "GitHub OIDC for ${var.repository_name} pull request."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.repository_name}:pull_request"
}



# Grant contributor role in current Azure subscription
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

# Grant each SP access to the Azure subscription
resource "azurerm_role_assignment" "oidc" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.oidc.object_id
}

# Create the Azure Storage account for state data
resource "random_integer" "oidc" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "oidc" {
  name     = "branch-based-${random_integer.oidc.result}"
  location = var.azure_region
}

resource "azurerm_storage_account" "oidc" {
  resource_group_name = azurerm_resource_group.oidc.name
  location            = azurerm_resource_group.oidc.location
  name                = "branchbased${random_integer.oidc.result}"

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a container
resource "azurerm_storage_container" "ct" {
  name                 = "branchbased"
  storage_account_name = azurerm_storage_account.oidc.name
}

# Grant each SP access to its container for state data
resource "azurerm_role_assignment" "state" {
  scope                = azurerm_storage_container.ct.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.oidc.object_id
}

# GitHub secret creation
locals {
  secret_values = {
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    AZURE_TENANT_ID       = data.azuread_client_config.current.tenant_id
    AZURE_CLIENT_ID       = azuread_service_principal.oidc.application_id
    STORAGE_ACCOUNT       = azurerm_storage_account.oidc.name
    RESOURCE_GROUP_NAME   = azurerm_storage_account.oidc.resource_group_name
    CONTAINER_NAME        = azurerm_storage_container.ct.name
  }
}

data "github_repository" "oidc" {
  full_name = var.repository_name
}

resource "github_actions_secret" "oidc" {
  for_each        = local.secret_values
  secret_name     = each.key
  plaintext_value = each.value
  repository      = data.github_repository.oidc.name
}