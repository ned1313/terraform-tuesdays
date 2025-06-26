variable "prefix" {
  type = string
}

output "local_value" {
  value = "${var.prefix}-local"
  
}

output "path_module" {
  value = path.module
}

output "path_root" {
  value = path.root
}