output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
  description = "Public IP address of the VM."
}