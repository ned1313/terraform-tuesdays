variable "changeme" {
  type = string
}

resource "null_resource" "main" {
  triggers = {
    changeme = var.changeme
  }

  provisioner "local-exec" {
    command = "echo ${self.triggers.changeme}"
  }
}

resource "terraform_data" "main" {
  triggers_replace = var.changeme

  provisioner "local-exec" {
    command = "echo ${self.triggers_replace}"
  }
}