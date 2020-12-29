resource "azurerm_app_service" "fhir_server" {
  name                = "fhir-app-service"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|mcr.microsoft.com/healthcareapis/r4-fhir-server:latest"
  }

  app_settings = {
    always_on = "true"
  }
}