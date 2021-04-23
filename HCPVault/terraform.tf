terraform {
  required_providers {
      hcp = {
          source = "hashicorp/hcp"
          version = "~> 0.5"
      }
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

provider "hcp" {
  client_id = var.client_id
  client_secret = var.client_secret
}

provider "aws" {
  region = var.region
}