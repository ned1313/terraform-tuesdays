resource "random_string" "main" {
  length  = 8
  special = false
  upper   = false
}

output "name" {
  value = random_string.main.result
}