output "sqlserver_name" {
  value       = azurerm_sql_server.fhir_sql_server.name
  description = "The generated sql server name."
}

output "service_id" {
  value       = azurerm_app_service.fhir_server.id
  description = "The fhir app service id."
}