resource "azurerm_resource_group" "mysql" {
  name     = "${var.prefix}-mysql-rg"
  location = var.location

  tags = var.common_tags
}

resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.mysql.name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.prefix}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.mysql.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.prefix}-mysql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = azurerm_resource_group.mysql.name
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.prefix}-mysql-fs"
  resource_group_name    = azurerm_resource_group.mysql.name
  location               = azurerm_resource_group.mysql.location
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "GP_Standard_D2ds_v4"

  tags = var.common_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}