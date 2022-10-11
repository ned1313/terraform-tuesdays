variable "taco_object" {
  type = object({
    meat   = string
    cheese = optional(string, "cheddar")
    salsa  = optional(string)
  })
}

locals {
    salsa = var.taco_object.salsa != null ? var.taco_object.salsa : "mild"
}

variable "burrito_object" {
  type = object({
    meat = string
    rice = optional(string)
    toppings = optional(object({
      cheese = optional(string, "cheddar")
      salsa  = optional(string)
    }))
  })
}

variable "taco_with_toppings" {
  type = object({
    meat   = string
    cheese = optional(string, "cheddar")
    salsa  = optional(string)
    toppings = optional(list(any), ["lettuce", "tomato"])
  })
}