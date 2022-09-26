# Module for storage account with containers for each environment

# Module for Service Principals
data "azuread_client_config" "current" {}

module "oidc_sp" {
  for_each = toset(keys(var.env_sub_ids))
  source   = "ned1313/github_oidc/azuread"
  version  = ">=1.0.0"

  entity_type      = "environment"
  environment_name = each.value
  identity_name    = "oidc-test-${each.value}"
  repository_name  = var.repository_name
}


# Configure the federated application settings

# GitHub environment creation
data "github_repository" "oidc" {
  full_name = var.repository_name
}

resource "github_repository_environment" "oidc" {
  for_each    = toset(keys(var.env_sub_ids))
  environment = each.value
  repository  = data.github_repository.oidc.name
}

# GitHub secret creation
locals {
  secret_values = flatten([for env, sub in var.env_sub_ids : [
    {
      environment  = env
      secret_name  = "AZURE_SUBSCRIPTION_ID"
      secret_value = sub
    },
    {
      environment  = env
      secret_name  = "BACKEND_SUBSCRIPTION_ID"
      secret_value = data.azurerm_subscription.current.subscription_id
    },
    {
      environment  = env
      secret_name  = "AZURE_TENANT_ID"
      secret_value = data.azuread_client_config.current.tenant_id
    },
    {
      environment  = env
      secret_name  = "AZURE_CLIENT_ID"
      secret_value = module.oidc_sp[env].service_principal.application_id
    },
    {
      environment  = env
      secret_name  = "STORAGE_ACCOUNT"
      secret_value = azurerm_storage_account.oidc.name
    },
    {
      environment  = env
      secret_name  = "RESOURCE_GROUP_NAME"
      secret_value = azurerm_storage_account.oidc.resource_group_name
    },
    {
      environment  = env
      secret_name  = "CONTAINER_NAME"
      secret_value = azurerm_storage_container.ct[env].name
    }]
  ])
}

resource "github_actions_environment_secret" "oidc" {
  for_each        = { for item in local.secret_values : "${item.environment}_${item.secret_name}" => item }
  environment     = each.value.environment
  secret_name     = each.value.secret_name
  plaintext_value = each.value.secret_value
  repository = data.github_repository.oidc.name
}

# Github branch creation
resource "github_branch" "oidc" {
  for_each = toset(keys(var.env_sub_ids))
  repository = data.github_repository.oidc.name
  branch = each.value
}

# Branch protection rules
resource "github_branch_protection" "oidc" {
  for_each = toset(keys(var.env_sub_ids))
  repository_id = data.github_repository.oidc.node_id

  pattern = each.value
  required_pull_request_reviews {
    dismiss_stale_reviews  = true
    required_approving_review_count = 1
  }
}

# Grant contributor role in each Azure subscription
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "oidc" {
  for_each = var.env_sub_ids
  scope = "/subscriptions/${each.value}"
  role_definition_name = "Contributor"
  principal_id = module.oidc_sp[each.key].service_principal.object_id
}

# Create the Azure Storage account for state data
resource "random_integer" "oidc" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "oidc" {
  name = "oidc-${random_integer.oidc.result}"
  location = var.azure_region
}

resource "azurerm_storage_account" "oidc" {
  resource_group_name = azurerm_resource_group.oidc.name
  location = azurerm_resource_group.oidc.location
  name = "oidc${random_integer.oidc.result}"

  account_tier = "Standard"
  account_replication_type = "LRS"
}

# Create a container for each environment
resource "azurerm_storage_container" "ct" {
  for_each = toset(keys(var.env_sub_ids))
  name                 = lower(each.value)
  storage_account_name = azurerm_storage_account.oidc.name
}

# Grant each SP access to its container for state data
resource "azurerm_role_assignment" "state" {
  for_each = toset(keys(var.env_sub_ids))
  scope = azurerm_storage_container.ct[each.value].resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = module.oidc_sp[each.value].service_principal.object_id
}