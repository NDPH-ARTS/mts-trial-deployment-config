output "service_id" {
  value       = azurerm_app_service.generic_service.id
  description = "The id of the generated app service."
}

output "endpoint" {
  value       = azurerm_app_service.generic_service.outbound_ip_addresses
  description = "The public endpoint."
}