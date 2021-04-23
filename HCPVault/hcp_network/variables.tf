## Cloud Provider Information
variable "cloud_provider" {
  description = "Cloud provider to use for HVN - AWS is the default"
  type = string
  default = "aws"
}

variable "cloud_region" {
  description = "Region in the cloud provider where you want to create the HVN - AWS us-east-1 is default"
  type = string
  default = "us-east-1"
}

## HVN Information
variable "hvn_cidr_block" {
  description = "CIDR block for the HVN deployment"
  type = string
  default = "172.16.0.0/24"
}

variable "prefix" {
  description = "Naming prefix for HVN resource"
  type = string
  default = "taco"
}

