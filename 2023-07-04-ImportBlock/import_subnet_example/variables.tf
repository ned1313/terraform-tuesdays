variable "azure_region" {
  type        = string
  description = "(Optional) Region of Azure to use for resources. Defaults to East US."
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of resource group."
}

variable "vnet_name" {
  type        = string
  description = "(Required) Name of virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "(Required) Address space for virtual network."
}

variable "subnets" {
  type        = map(string)
  description = "(Required) Map of subnet names and address prefixes."
}