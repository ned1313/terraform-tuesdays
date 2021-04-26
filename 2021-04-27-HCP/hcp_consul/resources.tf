locals {
  name = "${lower(var.prefix)}-${random_id.seed.hex}"
}

resource "random_id" "seed" {
  byte_length = 4
}

resource "hcp_consul_cluster" "consul" {
  cluster_id = local.name
  hvn_id     = var.hvn_id
  tier       = var.tier
  public_endpoint = var.public_endpoint
}

resource "hcp_consul_cluster_root_token" "consul" {
  cluster_id = hcp_consul_cluster.consul.cluster_id
}