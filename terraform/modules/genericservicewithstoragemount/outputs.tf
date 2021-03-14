output "service_id" {
  value       = azurerm_app_service.generic_service_with_storage_mount.id
  description = "The id of the generated app service."
}

output "name" {
  value       = azurerm_app_service.generic_service_with_storage_mount.name
  description = "The public endpoint."
}

output "hostname" {
  value       = "https://${azurerm_app_service.generic_service_with_storage_mount.default_site_hostname}"
  description = "The default hostname of the web app."
}

output "identity" {
  value = azurerm_app_service.generic_service_with_storage_mount.identity[0].principal_id
}
