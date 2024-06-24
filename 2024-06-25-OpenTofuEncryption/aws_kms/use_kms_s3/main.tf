resource "local_file" "main" {
  content  = "Encrypt state and plan again!"
  filename = "${path.module}/testplan2.txt"
}

output "test" {
  value = local_file.main.filename
}