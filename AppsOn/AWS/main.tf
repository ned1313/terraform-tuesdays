###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"

    }
  }

  backend "azurerm" {
    
  }
}

###########################
# VARIABLES
###########################

variable "region" {
  type        = string
  description = "Region in AWS"
  default     = "us-east-1"
}

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "churros"
}

###########################
# PROVIDERS
###########################

provider "aws" {
    region = var.region
}

###########################
# DATA SOURCES
###########################

locals {
  name = "${var.prefix}-${random_id.seed.hex}"
}

###########################
# RESOURCES
###########################

resource "random_id" "seed" {
  byte_length = 4
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = local.name
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a","us-east-1b"]
  private_subnets = []
  public_subnets = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
  enable_nat_gateway = false

}