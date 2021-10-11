terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }
}

provider "google-beta" {
  region = var.region
  zone   = var.zone
}

provider "google" {
    region = var.region
    zone   = var.zone
}