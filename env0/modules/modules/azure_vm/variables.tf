variable "resource_group_name" {
  type = string
  description = "Resource group name for all module resources."
}

variable "region" {
  type = string
  description = "Region for all module resources."
}

variable "subnet_id" {
  type = string
  description = "Subnet ID for the network interface."
}