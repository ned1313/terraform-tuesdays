################ 🌮🌮🌮 ############################

variable "meat" {
  type = string
  default = "chicken"
  description = "Type of meat to put on the taco."
}

variable "cheese" {
  type = string
  default = "jack"
  description = "Type of cheese to put on the taco."
}

variable "shell" {
  type = string
  default = "crunchy"
  description = "Type of shell to use for the taco."
}

module "my_salsa" {
    source = "./salsa"
    
    meat = var.meat
}

locals {
  taco = {
      meat = var.meat
      cheese = var.cheese
      shell = var.shell
      salsa = module.my_salsa.salsa
  }
}

output "taco" {
  value = local.taco
}