terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }
}


provider "google" {
  region = var.region
}