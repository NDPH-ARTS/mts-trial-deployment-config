output "service_id" {
  value       = azurerm_app_service.init_service.id
  description = "The id of the generated app service."
}

output "name" {
  value       = azurerm_app_service.init_service.name
  description = "The public endpoint."
}

output "hostname" {
  value       = "https://${azurerm_app_service.init_service.default_site_hostname}"
  description = "The default hostname of the web app."
}

output "identity" {
  value = azurerm_app_service.init_service.identity[0].principal_id
}
