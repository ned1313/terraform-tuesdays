# Create Service Principals
data "azuread_client_config" "current" {}

module "oidc_sp" {
  source  = "ned1313/github_oidc/azuread"
  version = ">=1.0.0"

  entity_type     = "ref"
  ref_branch      = var.ref_branch
  identity_name   = "oidc-simple-${random_integer.oidc.result}"
  repository_name = var.repository_name
}

## Add a pull_request federated credential to the Service Principal
resource "azuread_application_federated_identity_credential" "oidc_pr" {
  application_object_id = module.oidc_sp.azuread_application.object_id
  display_name          = "${module.oidc_sp.service_principal.display_name}-pr"
  description           = "GitHub OIDC for ${var.repository_name} PRs."
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.repository_name}:pull_request"
}

# Grant contributor role in current Azure subscription
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "oidc" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = module.oidc_sp.service_principal.object_id
}

# Create the Azure Storage account for state data
resource "random_integer" "oidc" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "oidc" {
  name     = "oidc-${random_integer.oidc.result}"
  location = var.azure_region
}

resource "azurerm_storage_account" "oidc" {
  resource_group_name = azurerm_resource_group.oidc.name
  location            = azurerm_resource_group.oidc.location
  name                = "oidc${random_integer.oidc.result}"

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a container
resource "azurerm_storage_container" "ct" {
  name                 = "oidc-test"
  storage_account_name = azurerm_storage_account.oidc.name
}

# Grant the SP access to its container for state data
resource "azurerm_role_assignment" "state" {
  scope                = azurerm_storage_container.ct.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.oidc_sp.service_principal.object_id
}

# GitHub secret creation
locals {
  secret_values = {
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    AZURE_TENANT_ID       = data.azuread_client_config.current.tenant_id
    AZURE_CLIENT_ID       = module.oidc_sp.service_principal.application_id
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
