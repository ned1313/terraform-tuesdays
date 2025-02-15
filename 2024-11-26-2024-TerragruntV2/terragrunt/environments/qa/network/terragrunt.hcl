include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//network"
}

inputs = {
  cidr_block = "10.2.0.0/16"
  subnets = {
    frontend = {
      address_prefixes = "10.2.0.0/24"
    }
    backend = {
      address_prefixes        = "10.2.1.0/24"
      delegation_name         = "aci-delegation"
      service_delegation_name = "Microsoft.ContainerInstance/containerGroups"
      service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
    db = {
      address_prefixes  = "10.2.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }
}