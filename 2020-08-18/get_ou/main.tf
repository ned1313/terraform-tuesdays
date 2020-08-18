terraform {
  required_providers {
    ad = {
      source = "hashicorp/ad"
      version = "0.1.0"
    }
  }
}

variable "winrm_password" {}

variable "winrm_username" {}

variable "winrm_hostname" {
  default = "adVM.tf.local"
}

provider "ad" {
    winrm_hostname = var.winrm_hostname
    winrm_password = var.winrm_password
    winrm_username = var.winrm_username
    winrm_port = 5985
    winrm_proto = "http"
}

data "ad_ou" "g" {
    dn = "OU=TF Users,dc=tf,dc=local"
}

output "ou_uuid" {
    value = data.ad_ou.g.id
}