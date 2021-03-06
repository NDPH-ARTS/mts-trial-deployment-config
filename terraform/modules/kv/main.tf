
resource "azurerm_key_vault" "trial_keyvault" {
  name                        = "kv-${var.trial_name}-${var.environment}"
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id

  sku_name = "standard"

  # define ACLs so that the KV will be in the vnet
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# Connect KV to a new private endpoint
module "private_endpoint" {
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  resource_id      = azurerm_key_vault.trial_keyvault.id
  subnet_id        = var.subnet_id
  subresource_name = "vault"
  application      = "kv"
  dns_zone_id      = var.dns_zone_id

  depends_on = [
    azurerm_key_vault.trial_keyvault,
  ]
}
