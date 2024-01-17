## Azure provider
provider "azurerm" {
  features {}
}

## First we need a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-castai"
  location = var.location
}

## And a virtual network
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.1.0"
  resource_group_name = azurerm_resource_group.main.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.main.location
  vnet_name           = "${var.prefix}-castai"
  address_space       = ["10.42.0.0/16"]
  subnet_names        = ["aks"]
  subnet_prefixes     = ["10.42.0.0/24"]
}

## We'll start by deploying an AKS cluster
module "aks" {
  source                            = "Azure/aks/azurerm"
  version                           = "7.5.0"
  resource_group_name               = azurerm_resource_group.main.name
  prefix                            = var.prefix
  role_based_access_control_enabled = true
  rbac_aad                          = false
  vnet_subnet_id                    = lookup(module.vnet.vnet_subnets_name_id, "aks")

  depends_on = [azurerm_resource_group.main]
}

## Probably should spin up a couple applications too
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

## Deploy an apache server
resource "kubernetes_deployment" "apache" {
  metadata {
    name = "php-apache"
  }

  spec {
    selector {
      match_labels = {
        run = "php-apache"
      }
    }

    template {
      metadata {
        labels = {
          run = "php-apache"
        }
      }

      spec {
        container {
          name  = "php-apache"
          image = "registry.k8s.io/hpa-example"

          port {
            container_port = 80
          }
          resources {
            limits = {
              cpu = "500m"
            }
            requests = {
              cpu = "200m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "apache" {
  metadata {
    name = "php-apache"
    labels = {
      run = "php-apache"
    }
  }

  spec {
    port {
      port = 80
    }
    selector = {
      run = "php-apache"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "apache" {
  metadata {
    name = "php-apache-hpa"
  }

  spec {
    max_replicas                      = 60
    min_replicas                      = 5
    target_cpu_utilization_percentage = 80

    scale_target_ref {
      kind        = "Deployment"
      name        = "php-apache"
      api_version = "apps/v1"
    }
  }
}

## And maybe we can set up a load generator?
resource "kubernetes_deployment" "load_gen" {
  metadata {
    name = "infinite-calls"
    labels = {
      app = "infinite-calls"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infinite-calls"
      }
    }
    template {
      metadata {
        name = "infinite-calls"
        labels = {
          app = "infinite-calls"
        }
      }
      spec {
        container {
          name  = "infinite-calls"
          image = "busybox"
          command = [
            "/bin/sh",
            "-c",
            "while true; do wget -q http://php-apache; done"
          ]
        }
      }
    }

  }
}