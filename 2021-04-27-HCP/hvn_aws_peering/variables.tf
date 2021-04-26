variable "peer_vpc_id" {
  description = "VPC ID of the VPC to be paired with the HVN"
  type = string
}

variable "hvn_id" {
  description = "ID of the HVN to be paired with the VPC"
  type = string
}

variable "route_table_ids" {
  description = "Route Table IDs to associate the peering connection with."
  type = list(string)
}

variable "hvn_cidr_block" {
  description = "CIDR Block of HVN for peered routing."
  type = string
}