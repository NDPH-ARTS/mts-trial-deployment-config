output "ui_conn_string" {
  value       = module.trial_rg.ui_conn_string
  description = "The UI storage account connection string."
  sensitive   = true
}

output "gateway_host" {
  value       = module.trial_rg.modules.trial_sc_gateway.genericservice.hostname
  description = "The hostname of the API gateway."
  sensitive = false
}