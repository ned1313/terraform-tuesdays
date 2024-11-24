output "backend_public_dns" {
  value = azurerm_container_group.backend.fqdn

}

output "backend_ip_address" {
  value = azurerm_container_group.backend.ip_address

}