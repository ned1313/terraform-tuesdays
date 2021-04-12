terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

variable "region" {
  type = string
  default = "us-east-1"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_kms_key" "ebs" {
  description = "EBS key"
}

resource "aws_ebs_volume" "encrypted" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  size              = 40
  encrypted = true
  kms_key_id = aws_kms_key.ebs.arn
}