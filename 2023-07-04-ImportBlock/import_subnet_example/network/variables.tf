variable "azure_region" {
  type        = string
  description = "Region of Azure to use for resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group to use."
}

variable "vnet_name" {
  type        = string
  description = "Name of virtual network to create."
}

variable "address_space" {
  type        = list(string)
  description = "List of address spaces to use with virtual network."
}

variable "subnets" {
  type        = map(string)
  description = "Name of subnet and address prefix"
}