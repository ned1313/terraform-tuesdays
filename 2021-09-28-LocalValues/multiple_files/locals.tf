resource "random_id" "seed" {
  byte_length = 4
}

locals {
  prefix = "${var.naming_prefix}-${random_id.seed.hex}"
}