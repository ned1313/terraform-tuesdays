variable "meat" {
  type = string
  default = "chicken"
}

variable "cheese" {
  type = string
  default = "jack"
}

variable "shell" {
  type = string
  default = "corn"
}

module "my_taco" {
    source = "./tacos"

    meat = var.meat
    cheese = var.cheese
    shell = var.shell
}

output "taco" {
  value = module.my_taco.taco
}