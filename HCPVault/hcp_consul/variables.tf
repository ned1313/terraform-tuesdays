variable "prefix" {
  description = "Naming prefix for Consul Cluster"
  type = string
  default = "taco"
}

variable "public_endpoint" {
  description = "Whether or not to create a public endpoint for Consul"
  type = bool
  default = false
}

variable "hvn_id" {
  description = "ID of the HVN to used with Consul"
  type = string
}

variable "tier" {
  description = "Tier of Consul to use, defaults to development"
  type = string
  default = "development"
}