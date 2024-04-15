locals {
  mymap = {
    one = "1"
    two = "2"
  }

  my_value = lookup(local.mymap, "three", "unknown")
  my_value2 = local.mymap["one"] # returns 1

  mystring = "a string of characters"
  my_int = 8
  my_double = 6.788
  my_bool = true

  ## Collections
  my_list = [0,5,9,9]
  my_element = local.my_list[0]
  my_map = {
    book = "read"
    floor = "table"
  }
  my_value3 = local.my_map["book"]
  all_values = values(local.my_map)

  ## Structural
  my_tuple = [0,"one",true]
  my_obj = {
    book = [1,2,3]
    floor = true
  }
}

variable "subnet_list" {
  type = list(string)
}

variable "subnet_details" {
  type = object({
    address_prefix = list(string)
    subnet_delegation = string 
  })
}

variable "my_weird_variable" {
  type = map(any)
}

resource "azurerm_resource_group" "maybe" {
  count = var.resource_group_name != "" ? 1 : 0
}