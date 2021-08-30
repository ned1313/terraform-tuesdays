# We are going to create a local value and expose it with an output

locals {
  my_string = "string value"
  my_list = ["one","two","three"]
  my_map = {
      one = "1"
      two = "2"
      three = "3"
  }
}

resource "random_integer" "random" {
  min = 10000
  max = 99999
}

output "my_string_out" {
  value = local.my_string
}

output "my_list_out" {
  value = local.my_list
}

output "my_map_out" {
  value = local.my_map
}

output "random_out" {
  value = random_integer.random
}