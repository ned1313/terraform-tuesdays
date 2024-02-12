resource "azurerm_network_security_group" "nsg" {
  name                = "web-rules"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  dynamic "security_rule" {
    for_each = var.nsg_security_rules
    iterator = rule

    content {
      name                       = rule.key
      priority                   = rule.value.priority
      protocol                   = rule.value.protocol
      destination_port_range     = rule.value.destination_port_range
      direction                  = rule.value.direction
      access                     = rule.value.access
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

}