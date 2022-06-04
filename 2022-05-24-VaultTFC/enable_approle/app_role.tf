resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "tfc-approle"
}

resource "vault_policy" "example" {
  name = "dev"

  policy = <<EOT
path "azure-dev/" {
  capabilities = ["read","list"]
}

path "azure-dev/*" {
  capabilities = ["read","list"]
}

path "auth/token/create" {
  capabilities = ["update"]
}
EOT
}

resource "vault_approle_auth_backend_role" "tfc_dev" {
  backend        = vault_auth_backend.approle.path
  role_name      = "dev-role"
  token_policies = ["default", "dev"]
}

resource "vault_approle_auth_backend_role_secret_id" "tfc_dev" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.tfc_dev.role_name
}

## Configure an Azure Secrets Manager
data "azurerm_subscription" "current" {}

resource "vault_azure_secret_backend" "tfc_dev" {
  path = "azure-dev"
  use_microsoft_graph_api = true
  subscription_id         = data.azurerm_subscription.current.subscription_id
  tenant_id               = data.azuread_client_config.current.tenant_id
  client_id               = azuread_service_principal.vault_tfc.application_id
  client_secret           = azuread_service_principal_password.vault_tfc.value
  environment             = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "dev_role" {
  backend = vault_azure_secret_backend.tfc_dev.path
  role = "dev-role"
  ttl = 300
  max_ttl = 600

  azure_roles {
    role_name = "Contributor"
    scope = "${data.azurerm_subscription.current.id}"
  }

  depends_on = [
    azurerm_role_assignment.dev_subscription
  ]
}