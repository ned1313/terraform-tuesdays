


variable "super_weird_variable" {
  type        = any
  description = "I don't know what to expect!"
}


locals {
  my_string = "I'm a string!"
  my_long_string = <<EOF
This is a long
string that spans ${length(var.super_weird_variable)} lines.
multiple lines.
EOF

  my_number = 42
  my_boolean = true

  my_list_variable  = ["I'm", "a", "list", "variable!"] # local.my_list_variable[1]
  
  my_map_variable = { # local.my_map_variable["key1"]
    key1 = "I'm a map variable!"
    key2 = "I'm another map variable!"
    key3 = ["I'm a list inside a map!"]
  }
}

variable "ip_address_prefix" {
  type        = string
  description = "The IP address prefix to use for the network"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.ip_address_prefix))
    error_message = "The IP address prefix must be a valid CIDR block"
  }
  
}

variable "create_nat_gw" {
  type = bool
  description = "Whether to create a NAT gateway for the network"
}

