locals {
    toppings = ["lettuce","tomatoes","jalapenos","onions"]
}

resource "local_file" "count_loop" {
    count = length(local.toppings)
    content     = "${local.toppings[count.index]}"
    filename = "${path.module}/${local.toppings[count.index]}.count"
}

resource "local_file" "for_each_loop" {
    for_each = toset(local.toppings)
    content     = "${each.value}"
    filename = "${path.module}/${each.value}.foreach"
}

locals {
    create_file = false
}

resource "local_file" "count_optional" {
    count = local.create_file ? 1 : 0
    content     = "Hello!"
    filename = "${path.module}/count-create.txt"
}

resource "local_file" "for_each_optional" {
    for_each = local.create_file ? toset(["1"]) : toset([])
    content     = "Hello!"
    filename = "${path.module}/for-each-create.txt"
}