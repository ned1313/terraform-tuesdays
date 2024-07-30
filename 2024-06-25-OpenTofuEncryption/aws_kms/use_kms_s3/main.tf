resource "local_file" "main" {
  content  = "Change contents!"
  filename = "${path.module}/testplan2.txt"
}

output "test" {
  value = local_file.main.filename
}