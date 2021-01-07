# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "sql-endpoint-dns-private-zone" {
  name                = "${var.sql_server_resource_name}.database.windows.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "private-endpoint-${var.trial_name}-${var.sql_server_resource_name}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "privateserviceconnection-${var.trial_name}-${var.sql_server_resource_name}"
    private_connection_resource_id = var.sql_server_resource_id
    is_manual_connection           = false
    subresource_names              = [ "sqlServer" ]
  }
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "endpoint-connection" {
  depends_on = [azurerm_private_endpoint.private_endpoint]
  name = azurerm_private_endpoint.private_endpoint.name
  resource_group_name = var.rg_name
}

# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "endpoint-dns-a-record" {
  #depends_on = [azurerm_mssql_server.kopi-sql-server]
  name = lower("${var.sql_server_resource_name}-dns-record")
  zone_name = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.name
  resource_group_name = var.rg_name
  ttl = 300
  records = [data.azurerm_private_endpoint_connection.endpoint-connection.private_service_connection.0.private_ip_address]
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-zone-to-vnet-link" {
  name = "sql-db-vnet-link"
  resource_group_name = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql-endpoint-dns-private-zone.name
  virtual_network_id = var.vnet_id
}