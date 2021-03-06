resource "random_password" "fhir_sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# Deploy a sql server and db for fhir before we create the web app
module "fhir_sql_server" {
  source      = "../sql"
  trial_name  = var.trial_name
  rg_name     = var.rg_name
  subnet_id   = var.endpointsubnet
  db_name     = "FHIR"
  app_name    = "fhir"
  sql_user    = var.fhir_sqluser
  sql_pass    = random_password.fhir_sql_password.result
  application = "sql-fhir"
  dns_zone_id = var.sql_dns_zone_id
}

# Fhir server
resource "azurerm_app_service" "fhir_server" {
  name                = "as-${var.trial_name}-fhir-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.fhir_image_name}:${var.fhir_image_tag}"
    always_on        = true
  }

  logs {
    http_logs {
      file_system {
        retention_in_mb   = 30 # in Megabytes
        retention_in_days = 30 # in days
      }
    }

    detailed_error_messages_enabled = true
    failed_request_tracing_enabled  = true
  }

  app_settings = {
    FHIRServer__Security__Enabled = "false"
    # TODO: replace with KeyVault reference
    SqlServer__ConnectionString                       = "Server=tcp:${module.fhir_sql_server.sqlserver_name}.database.windows.net,1433;Initial Catalog=FHIR;Persist Security Info=False;User ID=${module.fhir_sql_server.db_user};Password=${module.fhir_sql_server.db_password};MultipleActiveResultSets=False;Connection Timeout=30;"
    SqlServer__AllowDatabaseCreation                  = "true"
    SqlServer__Initialize                             = "true"
    SqlServer__SchemaOptions__AutomaticUpdatesEnabled = "true"
    DataStore                                         = "SqlServer"
    WEBSITES_PORT                                     = 8080
    WEBSITE_DNS_SERVER                                = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL                            = 1
    ApplicationInsights__InstrumentationKey           = var.app_insights_key
  }

  depends_on = [
    module.fhir_sql_server,
  ]
}

module "private_endpoint" {
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  resource_id      = azurerm_app_service.fhir_server.id
  subnet_id        = var.endpointsubnet
  subresource_name = "sites"
  application      = "fhir"
  dns_zone_id      = var.webapp_dns_zone_id

  depends_on = [
    azurerm_app_service.fhir_server,
  ]
}