provider "aws" {
  region = var.aws_regions[0]
}

provider "aws" {
  alias  = "alternate"
  region = var.aws_regions[1]

}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zones" "available_alternate" {
  provider = aws.alternate
  state    = "available"
}

module "vpc_region1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.prefix}-${var.aws_regions[0]}-vpc"
  cidr = var.vpc_config_by_region[var.aws_regions[0]].cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets = var.vpc_config_by_region[var.aws_regions[0]].public_subnets

  enable_nat_gateway = false

  tags = var.tags
}

module "vpc_region2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.alternate
  }

  name = "${var.prefix}-${var.aws_regions[1]}-vpc"
  cidr = var.vpc_config_by_region[var.aws_regions[1]].cidr

  azs            = slice(data.aws_availability_zones.available_alternate.names, 0, 3)
  public_subnets = var.vpc_config_by_region[var.aws_regions[1]].public_subnets

  enable_nat_gateway = false

  tags = var.tags
}
