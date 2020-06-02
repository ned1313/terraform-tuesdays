#######################################################################################
# VARIABLES
#######################################################################################

variable "consul_address" {
  type = string
  description = "Address of Consul server"
  default = "127.0.0.1"
}

variable "consul_port" {
  type = number
  description = "Port Consul server is listening on"
  default = "8500"
}

variable "consul_datacenter" {
  type = string
  description = "Name of the Consul datacenter"
  default = "dc1"
}



#######################################################################################
# PROVIDERS
#######################################################################################

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

#######################################################################################
# DATA SOURCE
#######################################################################################

data "consul_keys" "networking" {
  key {
    name    = "vpc_cidr"
    path    = "terraform/vpc/${terraform.workspace}/cidr_range"
    default = "10.3.0.0/16"
  }
}

#######################################################################################
# OUTPUTS
#######################################################################################

output "vpc_cidr" {
  value = data.consul_keys.networking.var.vpc_cidr
}
