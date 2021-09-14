variable "remote_ip_address" {
  type        = string
  description = "IP Address of the remote system running libvirt."
}

variable "private_key_path" {
  type        = string
  description = "File path to the private key used to connect to the remote system"
}

variable "known_hosts" {
  type        = string
  description = "File path to the known hosts file"
}

variable "vm_pool_path" {
  type        = string
  description = "Path on remote machine to use for creating a storage pool"
  default     = "/vms"
}

variable "vm_count" {
  type        = number
  description = "Number of VMs to create on remote host"
  default     = 1
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for hostnames of VMs"
  default     = "taco"
}

variable "autostart" {
  type        = bool
  description = "Autostart the VMs"
  default     = true
}

variable "vm_memory" {
  description = "RAM in MB"
  type        = string
  default     = "1024"
}

variable "vm_vcpu" {
  type        = number
  description = "Number of vCPUs"
  default     = 1
}

variable "bridge" {
  type        = string
  description = "Bridge interface"
  default     = "virbr0"
}

variable "base_image_name" {
  type        = string
  description = "Image name that forms the base for the virtual machines"
  default     = "ubuntu-1804"
}

variable "base_image_uri" {
  type        = string
  description = "URI where the base image can be found, needs to be HTTPS"
  default     = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
}

locals {
  libvirt_uri = "qemu+ssh://azureuser@${var.remote_ip_address}/system?keyfile=${var.private_key_path}&known_hosts_verify=auto&known_hosts=${var.known_hosts}"
}