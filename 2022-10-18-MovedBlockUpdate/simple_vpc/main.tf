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

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.subnet.id
  route_table_id = aws_route_table.public.id
}

/*
module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = "Move VPC"
  cidr                 = "192.168.0.0/22"
  enable_dns_hostnames = true

  azs            = [data.aws_availability_zones.available.names[0]]
  public_subnets = ["192.168.0.0/24"]
}
*/

/*
moved {
  from = aws_vpc.vpc
  to   = module.main.aws_vpc.this[0]
}

moved {
  from = aws_internet_gateway.igw
  to   = module.main.aws_internet_gateway.this[0]
}

moved {
  from = aws_subnet.subnet
  to   = module.main.aws_subnet.public[0]
}

moved {
  from = aws_route.default_route
  to   = module.main.aws_route.public_internet_gateway[0]
}

moved {
  from = aws_route_table.public
  to   = module.main.aws_route_table.public[0]
}

moved {
  from = aws_route_table_association.public
  to   = module.main.aws_route_table_association.public[0]
}
*/

locals {
  long_string = <<EOF
This is a long string with ${local.other_value}
that spans multiple lines
EOF

other_value = "ned"
some_number = 42
some_bool   = true

some_list = [
  "a",
  "b",
  "c",
]

list_item = local.some_list[1]

some_map = {
  a = "b"
  c = "d"
}

map_item = local.some_map["a"]

some_object = object({
  a = "b"
  c = "d"
  e = [
    "f",
    "g",
    "h",]
 })

 some_tuple = tuple([
   "a",
   "b",
   "c",
 ])
}

variable "resource_group" {
  type = object({
    name = string
    location = string
  })
}

locals {
  mynum = 42
  cond = local.mynum > 0 ? "positive" : local.mynum == 0 ? "zero" : "negative"
}