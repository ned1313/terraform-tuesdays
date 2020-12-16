remote_state {
    backend = "azurerm"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
    config = {
        #Paste config here
    }
}

generate "terraform-config" {
  path = "terraform-config.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"

    }
  }
}
EOF
}

generate "providers" {
    path = "providers.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
provider "azurerm" {
    features {}
}
EOF
}