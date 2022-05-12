provider "azurerm" {
  features {}
  client_id       = data.vault_azure_access_credentials.creds.client_id
  client_secret   = data.vault_azure_access_credentials.creds.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

provider "vault" {
    namespace = var.vault_namespace
  auth_login {
    path = "auth/${var.approle_path}/login"
    namespace = var.vault_namespace
    parameters = {
      role_id   = var.role_id
      secret_id = var.secret_id
    }
  }
}

data "vault_azure_access_credentials" "creds" {
  backend                     = var.vault_azure_secret_backend_path
  role                        = var.vault_azure_secret_backend_role_name
  validate_creds              = true
  num_sequential_successes    = 3
  num_seconds_between_tests   = 1
  max_cred_validation_seconds = 100
}

# Create a single resource group
resource "azurerm_resource_group" "test" {
  name     = "approle-test"
  location = "eastus"
}