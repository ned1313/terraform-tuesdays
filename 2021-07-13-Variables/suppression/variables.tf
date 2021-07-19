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

variable "phone_number" {
  type = string
  sensitive = true
  default = "867-5309"
}

locals {
  my_taco = {
      protein = var.protein
      cheese = var.cheese
      toppings = var.toppings
      phone_number = var.phone_number
  }

  my_number = nonsensitive(var.phone_number)
}

#output "phone_number" {
#  value = var.phone_number
#}