resource "azurerm_linux_virtual_machine" "main" {
  name = var.computer_name
}

variable "computer_name" {
  
}

output "private_ip" {
  value = "https://${azurerm_linux_virtual_machine.main.private_ip_address}/index.html"
}