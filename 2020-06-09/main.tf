### Let's play with conditional logic!
variable "my_boo" {
    type = bool
    default = true
}

variable "my_int" {
    type = number
    default = 1
}

variable "my_string" {
    type = string
    default = ""
}

locals {
    a_test = var.my_boo ? "True!" : "False!"
    b_test = var.my_int > 0 ? "More than 0" : "Less than 0"
    workspace_map = {
        dev = "This is my dev content"
        prod = "This is my prod content"
    }
}

output "out_1" {
    value = local.a_test
}

output "out_2" {
    value = local.b_test
}

/*

resource "local_file" "workspace_file" { 
  count = terraform.workspace == "default" ? 0 : 1
  content = local.workspace_map[terraform.workspace]
  #content = terraform.workspace != "default" ? local.workspace_map[terraform.workspace] : ""
  filename = "${path.module}/${terraform.workspace}.txt"
}

*/

/*

resource "local_file" "workspace_file_2" { 
  count = contains(keys(local.workspace_map),terraform.workspace) ? 1 : 0
  content = contains(keys(local.workspace_map),terraform.workspace) ? local.workspace_map[terraform.workspace] : ""
  filename = "${path.module}/${terraform.workspace}_2.txt"
}

*/