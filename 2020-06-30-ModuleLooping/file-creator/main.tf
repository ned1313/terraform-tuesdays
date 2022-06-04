resource "local_file" "my_file" {
  content  = var.content
  filename = "${path.root}/${var.filename}"
}