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

locals {
    users = {
        user1 = {
            principal_name = "adent"
            sam_account_name = "adent"
            display_name = "Arthur Dent"
            container = "OU=TF Users,DC=tf,DC=local"
        },
        user2 = {
            principal_name = "fprefect"
            sam_account_name = "fprefect"
            display_name = "Ford Prefect"
            container = "OU=TF Users,DC=tf,DC=local"
        },
        user3 = {
            principal_name = "zbeeblebrox"
            sam_account_name = "zbeeblebrox"
            display_name = "Zaphod Beeblebrox"
            container = "OU=TF Users,DC=tf,DC=local"
        }
    }
}

resource "ad_user" "u" {
  for_each = local.users

  principal_name   = each.value["principal_name"]
  sam_account_name = each.value["sam_account_name"]
  display_name     = each.value["display_name"]
  container = each.value["container"]
  initial_password = "P@$$w0rd"
}