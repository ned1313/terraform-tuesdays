variable "location" {
  default = "eastus"
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "subnet_names" {
  type = list(string)
  default = [
    "controllers",
    "subnet2",
    "subnet3",
  ]
}

variable "controller_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "controller_vm_count" {
  type    = number
  default = 1
}

variable "worker_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "worker_vm_count" {
  type    = number
  default = 3
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  controller_nic_nsg = "controller-nic-${random_id.id.hex}"
  worker_nic_nsg     = "worker-nic-${random_id.id.hex}"
  controller_vm = "controller-${random_id.id.hex}"
  worker_vm     = "worker-${random_id.id.hex}"
}