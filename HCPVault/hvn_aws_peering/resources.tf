data "aws_vpc" "peer" {
  id = var.peer_vpc_id
}

data "aws_arn" "peer" {
  arn = data.aws_vpc.peer.arn
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id              = var.hvn_id
  peer_vpc_id         = data.aws_vpc.peer.id
  peer_account_id     = data.aws_vpc.peer.owner_id
  peer_vpc_region     = data.aws_arn.peer.region
  peer_vpc_cidr_block = data.aws_vpc.peer.cidr_block_associations[0].cidr_block
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

resource "aws_route" "peer" {
  count = length(var.route_table_ids)
  route_table_id = var.route_table_ids[count.index]
  destination_cidr_block = var.hvn_cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}