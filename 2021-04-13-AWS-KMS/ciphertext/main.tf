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

resource "aws_kms_key" "cipher" {
  description = "Ciphertext"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation = true
}

resource "aws_kms_alias" "cipher" {
  name = "alias/cipherkey"
  target_key_id = aws_kms_key.cipher.key_id
}

# Let's do a ciphertext with the resource
# This HAS to be a symmetric key or Terraform won't do it

resource "aws_kms_ciphertext" "recipe" {
  key_id = aws_kms_key.cipher.key_id

  plaintext = <<EOF
{
  "shell": "flour",
  "meat": "chicken",
  "spice": "cinnamon"
}
EOF
}

data "aws_kms_secrets" "recipe" {
  secret {
    name = "recipe"
    payload = aws_kms_ciphertext.recipe.ciphertext_blob
  }
}

data "aws_kms_ciphertext" "recipe" {
  key_id = aws_kms_key.cipher.key_id

  plaintext = <<EOF
{
  "shell": "corn",
  "meat": "beef",
  "spice": "nutmeg"
}
EOF
}

output "resource_ciphertext" {
  value = aws_kms_ciphertext.recipe.ciphertext_blob
}

output "data_secret_plaintext" {
  value = data.aws_kms_secrets.recipe.plaintext["recipe"]
}

output "data_ciphertext" {
  value = data.aws_kms_ciphertext.recipe.ciphertext_blob
}

output "key_id" {
  value = aws_kms_key.cipher.key_id
}