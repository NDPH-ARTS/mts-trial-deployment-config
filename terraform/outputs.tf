output "ui_conn_string" {
  value       = module.trial_rg.ui_conn_string
  description = "The UI storage account connection string."
  sensitive   = true
}

output "gateway_host" {
  value       = module.trial_rg.gateway_host
  description = "The hostname of the API gateway."
  sensitive   = false
}

output "init_storage_conn_string" {
  value       = module.trial_rg.init_storage_conn_string
  description = "The init service storage account connection string."
  sensitive   = true
}

