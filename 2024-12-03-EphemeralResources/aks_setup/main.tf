provider "azurerm" {
  features {}
}

resource "random_integer" "naming" {
  min = 10000
  max = 99999
}

locals {
  name = "ephemeral-aks-${random_integer.naming.result}"
}

resource "azurerm_resource_group" "aks" {
  name     = local.name
  location = "East US"
}

data "azurerm_client_config" "example" {

}

resource "azurerm_key_vault" "example" {
  name                = local.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.example.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.example.tenant_id
    object_id = data.azurerm_client_config.example.object_id

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "SetIssuers",
      "Update",
    ]
  }
}

module "aks" {
  source                            = "Azure/aks/azurerm"
  resource_group_name               = azurerm_resource_group.aks.name
  location                          = azurerm_resource_group.aks.location
  prefix                            = "ephaks"
  agents_count                      = 1
  role_based_access_control_enabled = true
  rbac_aad                          = false
  rbac_aad_azure_rbac_enabled       = false
}

resource "azurerm_key_vault_secret" "kube_config" {
  name         = "kubeconfig"
  value        = module.aks.kube_config_raw
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "client_certificate" {
  name         = "client-certificate"
  value        = module.aks.client_certificate
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "client_key" {
  name         = "client-key"
  value        = module.aks.client_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "cluster_ca_certificate" {
  name         = "cluster-ca-certificate"
  value        = module.aks.cluster_ca_certificate
  key_vault_id = azurerm_key_vault.example.id
}

output "key_vault_id" {
  value       = azurerm_key_vault.example.id
  description = "The ID of the Azure Key Vault."
}

output "aks_cluster_host" {
  value       = module.aks.cluster_fqdn
  description = "The Kubernetes cluster host."
}