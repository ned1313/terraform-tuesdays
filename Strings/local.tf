locals {
    my_list = [
        "foo",
        "bar",
        "baz",
    ]

    json_list = jsonencode(local.my_list)
}

resource "local_file" "list" {
  content = local.json_list
  filename = "local.json"
}