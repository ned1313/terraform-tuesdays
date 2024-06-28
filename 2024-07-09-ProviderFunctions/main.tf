terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.55.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
    vpc_id     = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
}