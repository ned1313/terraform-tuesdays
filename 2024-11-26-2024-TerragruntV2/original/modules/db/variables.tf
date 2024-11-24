variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
}

variable "location" {
  description = "The location where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}

variable "vnet_id" {
  description = "The ID of the virtual network"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}