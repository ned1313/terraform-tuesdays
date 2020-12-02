variable "meat" {
  type = string
  description = "The type of meat used on the taco, should match a value used in the local salsa variable."
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
  description = "Returns the type of salsa you should pair with your meat choice."
  value = local.salsa[var.meat]
}