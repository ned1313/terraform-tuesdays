resource "azurerm_resource_group" "backend" {
  name     = "${var.prefix}-be-rg"
  location = var.location
}

resource "azurerm_container_group" "backend" {
  name                = "${var.prefix}-be-cg"
  location            = azurerm_resource_group.backend.location
  resource_group_name = azurerm_resource_group.backend.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [var.subnet_id]


  container {
    name   = "backend-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  tags = var.common_tags
}