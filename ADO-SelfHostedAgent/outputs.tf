output "dns_hostname" {
  value = azurerm_container_group.main.fqdn
}

output "agent_pool_name" {
  value = local.agent_pool
}