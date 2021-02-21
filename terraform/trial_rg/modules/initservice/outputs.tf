output "service_id" {
  value       = azurerm_container_group.init_service.id
  description = "The id of the generated app service."
}

output "ip_address" {
  value       = azurerm_container_group.init_service.ip_address
  description = "The public endpoint."
}

output "fqdn" {
  value       = azurerm_container_group.init_service.fqdn
  description = "The FQDN of the container group."
}
