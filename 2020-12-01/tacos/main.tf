################ TACO TACO TACO ############################

variable "meat" {
  type = string
  default = "chicken"
  
  validation {
    condition = contains(["chicken","beef","fish","sofritas"], var.meat)
    error_message = "The meat must be in the list chicken, beef, pork, sofritas."
  }
}

variable "cheese" {
  type = string
  default = "jack"
  
  validation {
    condition = contains(["cheddar","jack","blanco","fresco"], var.cheese)
    error_message = "The cheese must be in the list cheddar, jack, blanco, fresco."
  }
}

variable "shell" {
  type = string
  default = "crunchy"
  
  validation {
    condition = contains(["corn","flour","crunchy"], var.shell)
    error_message = "The shell must be in the list corn, flour, crunchy."
  }
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