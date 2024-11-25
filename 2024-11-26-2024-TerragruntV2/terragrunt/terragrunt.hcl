# Load backend configuration from the backend.hcl file
locals {
  backend_config               = read_terragrunt_config(find_in_parent_folders("backend.hcl"))
  backend_container_name       = local.backend_config.locals.container_name
  backend_resource_group_name  = local.backend_config.locals.resource_group_name
  backend_storage_account_name = local.backend_config.locals.storage_account_name

  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  subscription_id = local.env_vars.locals.subscription_id
}

# Generate and Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
    subscription_id = "${local.subscription_id}"
}
EOF
}

# Generate a backend block
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = local.backend_resource_group_name
    storage_account_name = local.backend_storage_account_name
    container_name       = local.backend_container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

# Generate a Terraform required providers file
generate "terraform" {
  path      = "required_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "${local.env_vars.locals.azurerm_version}"
    }
  }
}
EOF
}

inputs = local.env_vars.locals