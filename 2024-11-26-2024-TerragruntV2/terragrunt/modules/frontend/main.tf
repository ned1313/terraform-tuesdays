resource "azurerm_resource_group" "frontend" {
  name     = "${var.prefix}-fe-rg"
  location = var.location
}

resource "azurerm_container_group" "frontend" {
  name                = "${var.prefix}-fe-cg"
  location            = azurerm_resource_group.frontend.location
  resource_group_name = azurerm_resource_group.frontend.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-frontend-dns"


  container {
    name   = "frontend-container"
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