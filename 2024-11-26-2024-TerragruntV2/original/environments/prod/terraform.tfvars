location        = "eastus"
subscription_id = "4d8e572a-3214-40e9-a26f-8f71ecd24e0d"
prefix          = "tgtest"
common_tags = {
  environment = "prod"
}

cidr_block = "10.1.0.0/16"
subnets = {
  frontend = {
    address_prefixes = "10.1.0.0/24"
  }
  backend = {
    address_prefixes        = "10.1.1.0/24"
    delegation_name         = "aci-delegation"
    service_delegation_name = "Microsoft.ContainerInstance/containerGroups"
    service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  }
  db = {
    address_prefixes  = "10.1.2.0/24"
    service_endpoints = ["Microsoft.Sql"]
  }
}