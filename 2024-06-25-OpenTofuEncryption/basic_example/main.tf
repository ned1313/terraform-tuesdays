resource "local_file" "main" {
  content  = "Encrypt state and plan!"
  filename = "${path.module}/testplan.txt"
}

output "test" {
  value = local_file.main.filename
}