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