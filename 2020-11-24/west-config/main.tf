terraform {
  backend "s3" {
    key    = "west-config"
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "region_1" {
  type    = string
  default = "us-east-1"
}

variable "region_2" {
  type    = string
  default = "us-west-1"
}


variable "vpc1_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc1_public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vpc2_cidr_range" {
  type    = string
  default = "10.1.0.0/16"
}

variable "vpc2_public_subnets" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}


#############################################################################
# PROVIDERS
#############################################################################

provider "aws" {
  version = "~> 2.0"
  region  = var.region_1
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region_2
  alias = "region2"
}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs_1" {}

data "aws_availability_zones" "azs_2" {
    provider = aws.region2
}

#############################################################################
# RESOURCES
#############################################################################  

module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  providers = {
      aws = aws.region2
  }

  name = "vpc2"
  cidr = var.vpc2_cidr_range
  enable_nat_gateway = false

  azs            = slice(data.aws_availability_zones.azs_2.names, 0, 2)
  public_subnets = var.vpc2_public_subnets

}
