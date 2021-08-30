data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  # Load all of the data from json
  vpc_json_data = jsondecode(file("network_data.json")).VPC
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "lt-vpc"
  version = "~> 2.0"

  cidr            = local.vpc_json_data.AddressSpace
  azs             = slice(data.aws_availability_zones.azs.names, 0, length(local.vpc_json_data.PublicSubnets))
  public_subnets  = local.vpc_json_data.PublicSubnets
  private_subnets = local.vpc_json_data.PrivateSubnets

  tags = local.vpc_json_data.Tags
}