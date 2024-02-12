output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_ids" {
  value = values(module.network.vnet_subnets_name_id)
}