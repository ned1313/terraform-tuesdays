##################################################################################
# VARIABLES
##################################################################################

variable "region_1" {
  type    = string
  default = "us-east-1"
}

variable "region_2" {
  type    = string
  default = "us-west-1"
}

#Bucket variables
variable "aws_prefix" {
  type    = string
  default = "taco"
}

variable "user_name" {
    type = string
    default = "Ned"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  version = "~>2.0"
  region  = var.region_1
}

provider "aws" {
  version = "~>2.0"
  region  = var.region_2
  alias = "replica"
}

##################################################################################
# RESOURCES
##################################################################################

module "remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"
  version = "0.4.1"

  s3_bucket_force_destroy = true
  state_bucket_prefix = var.aws_prefix
  replica_bucket_prefix = "${var.aws_prefix}-replica"
  dynamodb_table_name = "${var.aws_prefix}-tf-remote-state-lock"
  terraform_iam_policy_name_prefix = var.aws_prefix

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user       = var.user_name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}

##################################################################################
# OUTPUT
##################################################################################

output "dynamodb_table" {
  value = module.remote_state.dynamodb_table.name
}

output "s3_bucket" {
  value = module.remote_state.state_bucket.bucket
}

output "kmskey" {
  value = module.remote_state.kms_key.key_id
}

