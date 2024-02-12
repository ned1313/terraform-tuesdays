variable "naming_prefix" {
  description = "Prefix to use for naming of resources."
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources. Defaults to East US."
  type        = string
  default     = "eastus"
}

variable "common_tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
}

variable "vnet_address_space" {
  description = "List of address spaces to use for the VNET."
  type        = list(string)
}

variable "nsg_security_rules" {
  type = map(object({
    priority               = number
    protocol               = string
    direction              = string
    access                 = string
    destination_port_range = string
  }))
  description = "List of Security Rules to Create. Key is the name of the rule."
}

variable "subnet_configuration" {
  description = "Map of subnets to create in the VNET. Key is subnet name, value is address spaces."
  type        = map(string)
}