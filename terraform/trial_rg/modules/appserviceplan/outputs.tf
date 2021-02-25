output "id" {
  value       = var.shared_app_service_plan_id != "" ? var.shared_app_service_plan_id : azurerm_app_service_plan.app_service_plan[0].id
  description = "The app service plan id (to assign to web apps)"
}