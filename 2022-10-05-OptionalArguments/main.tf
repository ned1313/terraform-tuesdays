variable "taco_object" {
  type = object({
    meat   = string
    cheese = optional(string, "cheddar")
    salsa  = optional(string)
  })
}