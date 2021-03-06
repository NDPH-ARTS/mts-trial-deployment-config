# Trial Resource Group
resource "azurerm_resource_group" "trial_rg" {
  name     = "rg-trial-${var.trial_name}-${var.environment}"
  location = var.location
  tags = {
    Owner       = var.owner
    Environment = var.environment
    Ref         = var.github_ref
  }
}

## Service plan
resource "azurerm_app_service_plan" "apps_service_plan" {
  name                = "asp-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }

  depends_on = [
    azurerm_resource_group.trial_rg,
  ]
}

# Application insights
resource "azurerm_application_insights" "app_insights" {
  name                = "ai-${var.trial_name}-${var.environment}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  application_type    = "web"

  depends_on = [
    azurerm_resource_group.trial_rg,
  ]
}

# vnet
module "trial_vnet" {
  source     = "./modules/vnet"
  trial_name = var.trial_name
  rg_name    = azurerm_resource_group.trial_rg.name

  depends_on = [
    azurerm_resource_group.trial_rg,
  ]
}

# Fhir server (including sql server)
module "fhir_server" {
  source              = "./modules/fhir"
  trial_name          = var.trial_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id
  vnet_id             = module.trial_vnet.id
  endpointsubnet      = module.trial_vnet.endpointsubnet
  app_insights_key    = azurerm_application_insights.app_insights.instrumentation_key
  sql_dns_zone_id     = module.trial_vnet.sql_dns_zone_id
  webapp_dns_zone_id  = module.trial_vnet.webapp_dns_zone_id

  # needs an app service plan and an existing vnet
  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    azurerm_application_insights.app_insights,
    module.trial_vnet,
  ]
}

# Key vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
# TODO: HAS TO BE UNIQUE. https://ndph-arts.atlassian.net/browse/ARTS-367
module "trial_keyvault" {
  source      = "./modules/kv"
  trial_name  = var.trial_name
  environment = var.environment
  rg_name     = azurerm_resource_group.trial_rg.name
  tenant_id   = "99804659-431f-48fa-84c1-65c9609de05b"
  subnet_id   = module.trial_vnet.endpointsubnet
  dns_zone_id = module.trial_vnet.kv_dns_zone_id

  depends_on = [
    module.trial_vnet,
  ]
}

# Prepare an array of service ids so we can iterate on those and add them to the vnet
# loop-like style
locals {
  service_ids = [module.fhir_server.service_id, module.trial_app_service_site.service_id,
    module.trial_app_service_role.service_id,
    module.trial_app_service_practitioner.service_id,
    module.trial_app_service_init.service_id,
    module.trial_sc_gateway.service_id, module.trial_sc_discovery.service_id,
  module.trial_sc_config.service_id]
}

# Add vnet integration into each service (loop-like)
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_app_service_conn" {
  count          = length(local.service_ids)
  app_service_id = local.service_ids[count.index]
  subnet_id      = module.trial_vnet.integrationsubnet

  depends_on = [
    module.trial_vnet,
    module.fhir_server,
    module.trial_app_service_site,
    module.trial_app_service_role,
    module.trial_app_service_practitioner,
    module.trial_app_service_init,
    module.trial_sc_gateway,
    module.trial_sc_discovery,
    module.trial_sc_config
  ]
}

resource "random_password" "roles_sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# Create a roles and permissions SQL
# Deploy a sql server and db for fhir before we create the web app
module "roles_sql_server" {
  source      = "./modules/sql"
  trial_name  = var.trial_name
  rg_name     = azurerm_resource_group.trial_rg.name
  subnet_id   = module.trial_vnet.endpointsubnet
  db_name     = "ROLES"
  app_name    = "roles"
  sql_user    = "rolesuser"
  sql_pass    = random_password.roles_sql_password.result
  application = "sql-roles"
  dns_zone_id = module.trial_vnet.sql_dns_zone_id
}

# Storage account for UI elemenet
# TODO: HAS TO BE UNIQUE. https://ndph-arts.atlassian.net/browse/ARTS-367
resource "azurerm_storage_account" "uistorageaccount" {
  name                      = "sa${var.trial_name}ui${var.environment}"
  resource_group_name       = azurerm_resource_group.trial_rg.name
  location                  = azurerm_resource_group.trial_rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = true
  min_tls_version           = "TLS1_2"

  static_website {
    index_document = "index.html"
  }
}
