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

# Fhir server
module "fhir_server" {
  source              = "./modules/fhir"
  trial_name          = var.trial_name
  rg_name             = azurerm_resource_group.trial_rg.name
  app_service_plan_id = azurerm_app_service_plan.apps_service_plan.id

  depends_on = [
    azurerm_app_service_plan.apps_service_plan,
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

# Key vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
module "trial_keyvault" {
  source      = "./modules/kv"
  trial_name  = var.trial_name
  environment = var.environment
  rg_name     = azurerm_resource_group.trial_rg.name
  tenant_id   = "99804659-431f-48fa-84c1-65c9609de05b"
  subnet_id   = module.trial_vnet.subnet_id

  depends_on = [
    module.trial_vnet,
  ]
}

 # Add vnet integration to sql databases
resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  name                = "sql-vnet-rule"
  resource_group_name = azurerm_resource_group.trial_rg.name
  server_name         = module.fhir_server.sqlserver_name
  subnet_id           = module.trial_vnet.subnet_id

  depends_on = [
    azurerm_resource_group.trial_rg,
    module.trial_vnet,
  ]
}

locals {
  service_ids = [module.fhir_server.service_id, module.trial_app_service_site.service_id,
  module.trial_app_service_practitioner.service_id, module.trial_app_service_config.service_id,
  module.trial_sc_gateway.service_id, module.trial_sc_discovery.service_id,
  module.trial_sc_config.service_id]
}

# Add vnet integration into each service (loop-like)
resource "azurerm_app_service_virtual_network_swift_connection" "vnetappservice" {
  count           = length(local.service_ids)
  app_service_id  = local.service_ids[count.index]
  subnet_id       = module.trial_vnet.subnet_id

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