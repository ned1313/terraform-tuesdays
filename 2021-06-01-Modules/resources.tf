

resource "local_file" "taco_order" {
  content = jsonencode(local.taco)
  filename = "${path.module}/order.json"
}