# Create postgresql server
# Make sure to allow Azure services
resource "azurerm_postgresql_server" "boundary" {
  name                = local.pg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name

  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  sku_name   = "B_Gen5_2"
  version    = "11"
  storage_mb = 51200

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}

resource "azurerm_postgresql_firewall_rule" "boundary" {
  name                = "AllowaccesstoAzureservices"
  resource_group_name = azurerm_resource_group.boundary.name
  server_name         = azurerm_postgresql_server.boundary.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
