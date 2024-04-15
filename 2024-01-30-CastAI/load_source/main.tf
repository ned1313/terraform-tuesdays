data "terraform_remote_state" "aks" {
  backend = "local"
  config = {
    path = "../aks-cluster/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aks.outputs.host
  client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.aks.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.cluster_ca_certificate)
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