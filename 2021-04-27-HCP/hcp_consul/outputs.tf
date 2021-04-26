output "consul_private_endpoint_url" {
  value = hcp_consul_cluster.consul.consul_private_endpoint_url 
}

output "consul_public_endpoint_url" {
  value = hcp_consul_cluster.consul.consul_public_endpoint_url 
}

output "consul_admin_token" {
  value = hcp_consul_cluster_root_token.consul.secret_id
  sensitive = true
}

output "consul_ca_file" {
  value = hcp_consul_cluster.consul.consul_ca_file
}

output "consul_config_file" {
  value = hcp_consul_cluster.consul.consul_config_file
}