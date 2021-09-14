output "hypervisor_fqdn" {
  value = azurerm_public_ip.hypervisor.fqdn
}

output "hypervisor_public_ip" {
  value = azurerm_public_ip.hypervisor.ip_address
}