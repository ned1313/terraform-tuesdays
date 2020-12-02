variable "meat" {
  type = string
}

locals {
  salsa = {
      chicken = "tomatillo"
      beef = "picante"
      fish = "pineapple"
      sofritas = "pico"
  }
}

output "salsa" {
  value = local.salsa[var.meat]
}