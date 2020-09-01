variable "vault_aws_backend" {
    type = string
    description = "path to aws secrets engine"
    default = "aws"
}

variable "vault_aws_role" {
    type = string
    description = "name of aws role for credentials"
    default = "ec2-admin"
}

provider "vault" {
}

data "vault_generic_secret" "appkey" {
  path = "secret/appkey"
}

data "vault_aws_access_credentials" "creds" {
  backend = var.vault_aws_backend
  role    = var.vault_aws_role
  type = "sts"
}

output "data_json" {
    value = data.vault_generic_secret.appkey.data_json
}

output "vault_aws_creds" {
    value = data.vault_aws_access_credentials.creds
}

