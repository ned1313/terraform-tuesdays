variable "location" {
  description = "The location to use for the network"
  type        = string

}

variable "prefix" {
  description = "The prefix to use for the network"
  type        = string

}

variable "common_tags" {
  description = "The common tags to use for the network"
  type        = map(string)

}

variable "cidr_block" {
  description = "The CIDR block to use for the network"
  type        = string

}

variable "subnets" {
  type = map(object({
    address_prefixes           = string
    delegation_name            = optional(string)
    service_delegation_name    = optional(string)
    service_delegation_actions = optional(list(string))
    service_endpoints          = optional(list(string))
  }))
  description = "Map of subnets to create"
}