terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {
  type        = string
  description = "(Optional) Region to use for AWS resources"
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {

}


resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/22"
  enable_dns_hostnames = true

  tags = {
    Name = "Move VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

resource "aws_route" "default_route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


/*
module "vpc" {
  source = "./vpc_module"

  name                 = "Move VPC"
  cidr                 = "192.168.0.0/22"
  azs                  = [data.aws_availability_zones.available.names[0]]
  public_subnets       = ["192.168.0.0/24"]
  enable_nat_gateway   = false
  enable_dns_hostnames = true
}
*/

/*
moved {
  from = aws_vpc.vpc
  to   = module.vpc.aws_vpc.vpc
}

moved {
  from = aws_internet_gateway.igw
  to   = module.vpc.aws_internet_gateway.igw
}

moved {
  from = aws_route.default_route
  to   = module.vpc.aws_route.default_route
}

moved {
  from = aws_subnet.subnet
  to   = module.vpc.aws_subnet.subnets[0]
}
*/

