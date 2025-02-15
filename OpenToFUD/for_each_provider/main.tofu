provider "aws" {
  for_each = toset(var.aws_regions)
  alias    = "regions"
  region   = each.key
}

data "aws_availability_zones" "available" {
  for_each = toset(var.aws_regions)
  provider = aws.regions[each.key]
  state    = "available"
}

module "vpc" {
  for_each = toset(var.aws_regions)
  source   = "terraform-aws-modules/vpc/aws"
  version  = "~> 5.0"

  providers = {
    aws = aws.regions[each.key]
  }

  name = "${var.prefix}-${each.key}-vpc"
  cidr = var.vpc_config_by_region[each.key].cidr

  azs            = slice(data.aws_availability_zones.available[each.key].names, 0, 3)
  public_subnets = var.vpc_config_by_region[each.key].public_subnets

  enable_nat_gateway = false

  tags = var.tags
}
