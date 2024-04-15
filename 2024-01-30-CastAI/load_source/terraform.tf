terraform {
  required_version = "~>1.5"

  required_providers {

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.25"
    }

  }
}