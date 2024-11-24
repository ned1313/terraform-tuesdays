output "frontend_public_dns" {
  value = azurerm_container_group.frontend.fqdn

}