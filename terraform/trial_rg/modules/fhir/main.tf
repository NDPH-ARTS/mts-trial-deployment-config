resource "azurerm_app_service" "fhir_server" {
  name                = "trial-${var.trial_name}-fhir"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.fhir_image_name}:${var.fhir_image_tag}"
  }

  app_settings = {
    always_on                                         = "true"
    FHIRServer__Security__Enabled                     = "false"
    SqlServer__ConnectionString                       = "Server=tcp:sql,1433;Initial Catalog=FHIR;Persist Security Info=False;User ID=${var.fhirsqluser};Password=${var.fhirsqlpassword};MultipleActiveResultSets=False;Connection Timeout=30;"
    SqlServer__AllowDatabaseCreation                  = "true"
    SqlServer__Initialize                             = "true"
    SqlServer__SchemaOptions__AutomaticUpdatesEnabled = "true"
    DataStore                                         = "SqlServer"
    WEBSITES_PORT                                     = 8080
  }
}

resource "azurerm_sql_server" "fhir_sql_server" {
  name                         = "${var.trial_name}fhirsqlserver"
  location                     = var.location
  resource_group_name          = var.rg_name
  version                      = "12.0"
  administrator_login          = var.fhirsqluser
  administrator_login_password = var.fhirsqlpassword
}
