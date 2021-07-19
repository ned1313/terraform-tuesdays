variable "protein" {
    type = string
    default = "chicken"
}

variable "cheese" {
  type = string
  default = "cheddar"
  description = "Type of cheese to put on the taco."
}

variable "toppings" {
  type = list
  default = ["lettuce","tomato","jalapenos"]
}

locals {
  my_taco = {
      protein = var.protein
      cheese = var.cheese
      toppings = var.toppings
  }

}

output "my_taco" {
  value = local.my_taco
}