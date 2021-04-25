locals {
  name = "${lower(var.prefix)}-${random_id.seed.hex}"
}

resource "random_id" "seed" {
  byte_length = 4
}

resource "hcp_vault_cluster" "vault" {
  cluster_id = local.name
  hvn_id     = var.hvn_id
  public_endpoint = var.public_endpoint
}

resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = hcp_vault_cluster.vault.cluster_id
}