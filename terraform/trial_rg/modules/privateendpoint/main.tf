resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "pe-${var.trial_name}-${var.application}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "${var.application}privatednszonegroup"
    private_dns_zone_ids = [var.dns_zone_id]
  }

  private_service_connection {
    name                           = "psc-${var.trial_name}-${var.application}-${var.environment}"
    private_connection_resource_id = var.resource_id
    is_manual_connection           = false
    subresource_names              = [var.subresource_name]
  }
}

# Resource's Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "endpoint-connection" {
  depends_on          = [azurerm_private_endpoint.private_endpoint]
  name                = azurerm_private_endpoint.private_endpoint.name
  resource_group_name = var.rg_name
}

# Create a Resource's Private DNS A Record
resource "azurerm_private_dns_a_record" "endpoint-dns-a-record" {
  name                = lower("${var.application}-dns-record")
  zone_name           = var.dns_zone_name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.endpoint-connection.private_service_connection.0.private_ip_address]
}