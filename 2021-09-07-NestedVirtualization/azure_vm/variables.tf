variable "region" {
  type        = string
  description = "Region in Azure"
  default     = "eastus"
}

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "tacos"
}

variable "hypervisor_vm_size" {
  type        = string
  description = "Size for VM, must be Dv3 or Ev3"
  default     = "Standard_D4s_v3"
}

variable "data_disk_size" {
  type        = number
  description = "Size of data disk for VMs"
  default     = 256
}

variable "data_disk_storage_class" {
  type        = string
  description = "Storage class for the data disk"
  default     = "Premium_LRS"
}

resource "random_id" "seed" {
  byte_length = 4
}

locals {
  name          = "${var.prefix}-${random_id.seed.hex}"
  hypervisor_vm = "hypervisor-${random_id.seed.hex}"
}