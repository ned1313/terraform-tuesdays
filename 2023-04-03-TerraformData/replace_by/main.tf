variable "simple_string" {
  type    = string
  default = "cheese"
}

locals {
  simple_local = "can't touch this"
}

resource "terraform_data" "source" {
  input = var.simple_string
}

resource "terraform_data" "destination" {
  input = local.simple_local

  lifecycle {
    replace_triggered_by = [
      terraform_data.source
    ]
  }
}