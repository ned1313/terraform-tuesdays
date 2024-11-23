output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.network.id
}

output "subnet_id_map" {
  description = "Map of subnet IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }

}