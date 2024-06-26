provider "aws" {
  region = "us-west-2"
}

resource "random_integer" "bucket_suffix" {
  min = 10000
  max = 99999
}

data "aws_caller_identity" "current" {}

// Create a KMS key
resource "aws_kms_key" "tofu_key" {
  description              = "Tofu encryption key"
  enable_key_rotation      = true
  deletion_window_in_days  = 10
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "${data.aws_caller_identity.current.arn}"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

}

module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  version     = "1.4.1"
  
  force_destroy = true
  bucket_enabled = true
  dynamodb_enabled = true
  name = "encrypted${random_integer.bucket_suffix.result}"
  environment = "test"
  namespace = "tofu"

}

output "bucket_name" {
  value = module.terraform_state_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  value = module.terraform_state_backend.dynamodb_table_name
}

output "kms_id" {
  value = aws_kms_key.tofu_key.id
}