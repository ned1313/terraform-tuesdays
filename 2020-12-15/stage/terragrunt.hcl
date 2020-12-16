remote_state {
    backend = "azurerm"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
    config = {
        storage_account_name = "tacos76568"
        container_name = "terraform-state"
        key = "${path_relative_to_include()}/terraform.tfstate"
        sas_token = "?sv=2017-07-29&ss=b&srt=sco&sp=rwdlac&se=2022-12-16T00:15:10Z&st=2020-12-16T00:15:10Z&spr=https&sig=hRViR6HlZW4xHmYvq9GR%2Bj6pZm55w2A4GQTLsCu9kjY%3D"
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