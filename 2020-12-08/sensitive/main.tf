variable "my_secret" {
  type = string
  sensitive = true
}

variable "plaintext" {
  type = string
}

resource "local_file" "my_secret" {
  content = var.my_secret
  filename = "${path.module}/${var.my_secret}.txt"
}

resource "local_file" "plaintext" {
  content = var.plaintext
  filename = "${path.module}/${var.plaintext}.txt"
}

output "secret" {
  value = var.my_secret
  sensitive = true
}

output "plaintext" {
  value = var.plaintext
}