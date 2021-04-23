# AWS VPC Values
variable "vpcs" {
    description = "A list of VPC configurations to create and peer with the HVN. Uses the VPC module."
  type = list(object({
      name = string
      cidr = string
      azs = list(string)
      private_subnets = list(string)
      public_subnets = list(string)
      enable_nat_gateway = bool
  }))

  default = [{
      name = "peer-with-hvn"
      cidr = "10.0.0.0/16"
      azs = ["us-east-1a","us-east-1b"]
      private_subnets = []
      public_subnets = ["10.0.0.0/24","10.0.1.0/24"]
      enable_nat_gateway = false
  }]
}

variable "region" {
  description = "Region to use in AWS"
  default = "us-east-1"
  type = string
}

variable "keyname" {
  description = "Name of key pair to use with EC2 instance"
  type = string
}

## HCP Provider Values
variable "client_id" {
  description = "Client ID of service principal on HCP"
  type = string
  sensitive = true
}

variable "client_secret" {
  description = "Client secret of service principal on HCP"
  type = string
  sensitive = true
}