# In this configuration we are going to access the outputs from the 
# remote state stored for the networking.

data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "ned-in-the-cloud"

    workspaces = {
      name = "terraform-tuesday-modules-setup"
    }
   }
}

output "resource_group_name" {
  value = data.terraform_remote_state.network.outputs.resource_group_name
}

output "subnet_prefixes" {
  value = data.terraform_remote_state.network.outputs.subnet_prefixes
}

output "all_outputs" {
  value = data.terraform_remote_state.network.outputs
}