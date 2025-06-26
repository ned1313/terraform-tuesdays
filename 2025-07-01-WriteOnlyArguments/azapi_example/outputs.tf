output "resource_group_name" {
  value = local.resource_group_name
}

output "container_ipv4_address" {
  value = azapi_resource.container.output.properties.ipAddress.ip
}