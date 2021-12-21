terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.0"
    }
  }
}

# Use the TFE_TOKEN environment variable for TFE authentication