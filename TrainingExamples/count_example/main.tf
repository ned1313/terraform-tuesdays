resource "random_string" "many" {
  for_each = {
    one = 1
    two = 2
    three = 3
    four = 4
  }
  length = each.value + 10
}