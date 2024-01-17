terraform {
  required_version = "~>1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>2.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.25"
    }

    castai = {
      source  = "castai/castai"
      version = "~>6.2"
    }
  }
}