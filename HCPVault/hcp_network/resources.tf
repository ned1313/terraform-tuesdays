locals {
  name = "${lower(var.prefix)}-${random_id.seed.hex}"
}

resource "random_id" "seed" {
  byte_length = 4
}

resource "hcp_hvn" "hvn" {
  hvn_id         = local.name
  cloud_provider = var.cloud_provider
  region         = var.cloud_region
  cidr_block     = var.hvn_cidr_block
}

