include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//db"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnets = {
      "db" = {
        id = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue/subnets/subnetValue"
      }
    }
  }
}

inputs = {
  # Get the subnet id from the network module
  subnet_id = dependency.network.outputs.subnets["db"].id
}