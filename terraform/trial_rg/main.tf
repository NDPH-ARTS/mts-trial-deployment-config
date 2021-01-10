# Trial Resource Group

resource "azurerm_resource_group" "trial_rg" {
  name     = "rg-trial-${var.trial_name}-${var.environment}"
  location = var.location
  tags = {
    Owner = "user@contoso.com"
  }
}

## Service plan
resource "azurerm_app_service_plan" "apps_service_plan" {
  name                = "app-service-plan-${var.trial_name}"
  location            = azurerm_resource_group.trial_rg.location
  resource_group_name = azurerm_resource_group.trial_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }

  depends_on = [
    azurerm_resource_group.trial_rg,
  ]
}

# Audit storage
module "trial_audit" {
  source     = "./modules/audit"
  trial_name = var.trial_name
  rg_name    = azurerm_resource_group.trial_rg.name

  depends_on = [
    azurerm_resource_group.trial_rg,
  ]
}

# vnet
module "trial_vnet" {
  source      = "./modules/vnet"
  trial_name  = var.trial_name
  rg_name     = azurerm_resource_group.trial_rg.name

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
  subnet_id           = module.trial_vnet.sql_subnet_id

  # needs an app service plan and an existing vnet
  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
    module.trial_vnet,
  ]
}

# Key vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
module "trial_keyvault" {
  source      = "./modules/kv"
  trial_name  = var.trial_name
  environment = var.environment
  rg_name     = azurerm_resource_group.trial_rg.name
  tenant_id   = "99804659-431f-48fa-84c1-65c9609de05b"
  subnet_id   = module.trial_vnet.kv_subnet_id

  depends_on = [
    module.trial_vnet,
  ]
}

# Prepare an array of service ids so we can iterate on those and add them to the vnet
# loop-like style
locals {
  service_ids = [module.fhir_server.service_id, module.trial_app_service_site.service_id,
  module.trial_app_service_practitioner.service_id, module.trial_app_service_config.service_id,
  module.trial_sc_gateway.service_id, module.trial_sc_discovery.service_id,
  module.trial_sc_config.service_id]
}

# Add vnet integration into each service (loop-like)
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_app_service_conn" {
  count           = length(local.service_ids)
  app_service_id  = local.service_ids[count.index]
  subnet_id       = module.trial_vnet.webapps_subnet_id

  depends_on = [
    module.trial_vnet,
    module.fhir_server,
    module.trial_app_service_site,
    module.trial_app_service_practitioner,
    module.trial_app_service_config,
    module.trial_sc_gateway,
    module.trial_sc_discovery,
    module.trial_sc_config
  ]
}

resource "random_password" "roles_sql_password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Create a roles and permissions SQL
# Deploy a sql server and db for fhir before we create the web app
module "fhir_sql_server" {
  source     = "./modules/sql"
  trial_name = var.trial_name
  rg_name    = azurerm_resource_group.trial_rg.name
  vnet_id    = module.trial_vnet.id
  subnet_id  = module.trial_vnet.sql_subnet_id
  db_name    = "ROLES"
  app_name   = "roles"
  sql_user   = "rolesuser"
  sql_pass   = random_password.roles_sql_password.result
}