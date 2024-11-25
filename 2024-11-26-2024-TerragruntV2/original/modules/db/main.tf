resource "azurerm_resource_group" "postgres" {
  name     = "${var.prefix}-postgres-rg"
  location = var.location

  tags = var.common_tags
}


resource "azurerm_postgresql_server" "postgres" {
  name                = "${var.prefix}-postgres-server"
  location            = azurerm_resource_group.postgres.location
  resource_group_name = azurerm_resource_group.postgres.name

  sku_name = "GP_Gen5_2"

  storage_mb            = 5120
  backup_retention_days = 7


  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_virtual_network_rule" "postgres" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.postgres.name
  server_name                          = azurerm_postgresql_server.postgres.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = true
}