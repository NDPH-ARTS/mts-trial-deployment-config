output "service_id" {
  value       = azurerm_app_service.generic_service.id
  description = "The id of the generated app service."
}

output "name" {
  value       = azurerm_app_service.generic_service.name
  description = "The public endpoint."
}

output "hostname" {
  value       = "https://${azurerm_app_service.generic_service.name}.azurewebsites.net"
  description = "The hostname of the web app."
}
