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

data "aws_kms_key" "sse_key" {
  key_id = "alias/s3SseKey"
}

resource "aws_s3_bucket" "taco_bucket" {
  bucket = "taco-bucket-04122021"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_key.sse_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}