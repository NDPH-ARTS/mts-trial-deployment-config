resource "azurerm_app_service" "example" {
  name                = "example-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = "${ var.app_service_plan_id }"

  site_config {
    linux_fx_version = "DOCKER|mcr.microsoft.com/healthcareapis/r4-fhir-server:latest"
  }

  app_settings = {
    always_on = "true"
  }
}