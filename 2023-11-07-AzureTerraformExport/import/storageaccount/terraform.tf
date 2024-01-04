terraform {
  backend "local" {}

  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "1.9.0"

    }
  }
}
