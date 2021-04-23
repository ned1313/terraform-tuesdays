variable "peer_vpc_id" {
  description = "VPC ID of the VPC to be paired with the HVN"
  type = string
}

variable "hvn_id" {
  description = "ID of the HVN to be paired with the VPC"
  type = string
}