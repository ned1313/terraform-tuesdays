provider "azurerm" {
  features {}

}

ephemeral "azurerm_key_vault_secret" "k8s" {
  for_each = toset(["client-certificate", "client-key", "cluster-ca-certificate"])

  name         = each.key
  key_vault_id = var.key_vault_id
}

provider "kubernetes" {
  host = "https://${var.aks_cluster_host}"

  client_certificate     = base64decode(ephemeral.azurerm_key_vault_secret.k8s["client-certificate"].value)
  client_key             = base64decode(ephemeral.azurerm_key_vault_secret.k8s["client-key"].value)
  cluster_ca_certificate = base64decode(ephemeral.azurerm_key_vault_secret.k8s["cluster-ca-certificate"].value)
}


resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "terraform-example-namespace"
  }
}