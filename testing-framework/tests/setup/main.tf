resource "random_integer" "main" {
  min = 101
  max = 999
}

output "integer" {
  value = random_integer.main.result
}