variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string

}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

}

resource "azurerm_resource_group" "aks" {
  name     = "aks-rg"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks-dns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true


}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url

}

data "azurerm_kubernetes_cluster" "test" {
  resource_group_name = azurerm_resource_group.aks.name
    name                = azurerm_kubernetes_cluster.aks.name
}

output "ds_oidc_url" {
  value = data.azurerm_kubernetes_cluster.test.oidc_issuer_url
}