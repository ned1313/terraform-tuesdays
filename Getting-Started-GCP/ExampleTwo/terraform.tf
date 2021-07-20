terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }

  backend "remote" {
    organization = "ned-in-the-cloud"

    workspaces {
      name = "gcp-getting-started"
    }
  }
}