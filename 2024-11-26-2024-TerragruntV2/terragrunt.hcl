locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  subscription_id = local.env_vars.locals.subscription_id
  location        = local.env_vars.locals.location
  prefix          = local.env_vars.locals.prefix
  common_tags     = local.env_vars.locals.common_tags
}

inputs = local.env_vars.locals