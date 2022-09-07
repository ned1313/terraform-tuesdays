resource "local_file" "count_int_loop" {
  count = 3
  content = "This is file number ${count.index}"
  filename = "${path.module}/int-${count.index}.count"
}