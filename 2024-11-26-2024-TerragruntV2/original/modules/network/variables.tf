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
  type        = map(string)
  description = "Map of subnets to create"
}