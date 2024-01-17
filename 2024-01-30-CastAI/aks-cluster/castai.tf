# 3. Connect AKS cluster to CAST AI in READ-ONLY mode.

# Configure Data sources and providers required for CAST AI connection.
data "azurerm_subscription" "current" {}

provider "castai" {
  api_token = var.castai_api_token
  api_url   = var.castai_api_url
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

# Configure AKS cluster connection to CAST AI using CAST AI aks-cluster module.
module "castai-aks-cluster" {
  source = "castai/aks/castai"

  api_url                = var.castai_api_url
  castai_api_token       = var.castai_api_token
  grpc_url               = var.castai_grpc_url
  wait_for_cluster_ready = false

  aks_cluster_name    = module.aks.aks_name
  aks_cluster_region  = azurerm_resource_group.main.location
  node_resource_group = module.aks.node_resource_group
  resource_group      = azurerm_resource_group.main.name

  delete_nodes_on_disconnect = false

  subscription_id = data.azurerm_subscription.current.subscription_id
  tenant_id       = data.azurerm_subscription.current.tenant_id

  default_node_configuration = module.castai-aks-cluster.castai_node_configurations["default"]

  node_configurations = {
    default = {
      disk_cpu_ratio = 25
      subnets        = [lookup(module.vnet.vnet_subnets_name_id, "aks")]
      tags           = {}
    }
  }
}