variable "name" {
  type = string
  description = "(Required) Name of VPC to create."
}

variable "cidr" {
    type = string
    description = "(Required) CIDR block for VPC."
}

variable "azs" {
    type = list(string)
    description = "(Required) List of AZ names to use for resources."
}

variable "public_subnets" {
    type = list(string)
    description = "(Required) List of CIDR blocks for public subnets."
}

variable "enable_nat_gateway" {
  type = bool
  description = "(Optional) Whether to create a NAT gateway, default is false."
  default = false
}

variable "enable_dns_hostnames" {
  type = bool
  description = "(Optional) Whether to enabled DNS hostnames, default is false."
  default = false
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "subnets" {
  count = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]
}