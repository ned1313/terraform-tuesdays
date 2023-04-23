variable "complex_object" {}

resource "terraform_data" "trigger" {
  triggers_replace = var.complex_object

  provisioner "local-exec" {
    command = "echo WEEEEEEEEEEEEEE!"
  }
}

resource "terraform_data" "store" {
  input = var.complex_object
}

output "stored_data" {
  value = terraform_data.store.output
}