resource "local_file" "count_int_loop" {
  count = var.
  content = "This is file number ${count.index}"
  filename = "${path.module}/int-${count.index}.count"
}