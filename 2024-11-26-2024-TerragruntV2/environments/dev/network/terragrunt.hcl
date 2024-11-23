include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//network"
}

inputs = {
  cidr_block = "10.0.0.0/16"
  subnets = {
    "frontend" = "10.0.0.0/24"
    "backend"  = "10.0.1.0/24"
    "db"       = "10.0.2.0/24"
  }
}
