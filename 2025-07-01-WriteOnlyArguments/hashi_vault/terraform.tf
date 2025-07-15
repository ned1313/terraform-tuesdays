terraform {
  required_version = ">= 1.11.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}