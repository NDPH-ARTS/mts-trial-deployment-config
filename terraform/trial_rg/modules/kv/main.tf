
resource "azurerm_key_vault" "trial_keyvault" {
  name                        = "kv-${var.trial_name}"
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id

  sku_name = "standard"

  # define ACLs so that the KV will be in the vnet
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [ var.subnet_id ]
  }
}

# Connect KV to a new private endpoint
# module "private_endpoint" {
#   source                   = "../privateendpoint"
#   trial_name               = var.trial_name
#   rg_name                  = var.rg_name
#   sql_server_resource_name = azurerm_mssql_server.fhir_sql_server.name
#   sql_server_resource_id   = azurerm_mssql_server.fhir_sql_server.id
#   main_private_dns_name    = "trials.oxford"
#   vnet_id                  = var.vnet_id
#   subnet_id                = var.subnet_id
#
#   depends_on = [
#     azurerm_app_service.fhir_server,
#   ]
# }