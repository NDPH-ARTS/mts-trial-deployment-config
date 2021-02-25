## Service plan
resource "azurerm_app_service_plan" "app_service_plan" {
  count               = var.shared_app_service_plan_id != "" ? 0 : 1 # if the var is set we don't need to create a new plan
  name                = "asp-${var.trial_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }

  depends_on = [
  ]
}