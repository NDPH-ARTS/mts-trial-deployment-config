resource "azurerm_app_service" "fhir_server" {
  name                = "${var.trial_name}-fhir"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.fhir_image_name}:${var.fhir_image_tag}"
  }

  app_settings = {
    always_on = "true"
  }
}