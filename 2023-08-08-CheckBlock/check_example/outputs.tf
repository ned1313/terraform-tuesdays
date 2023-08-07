output "linux_public_ip" {
  value = data.azurerm_public_ip.pip.ip_address
}