variable "prefix" {
  description = "Naming prefix for Vault Cluster"
  type = string
  default = "taco"
}

variable "public_endpoint" {
  description = "Whether or not to create a public endpoint for Vault"
  type = bool
  default = false
}

variable "hvn_id" {
  description = "ID of the HVN to be paired with the VPC"
  type = string
}