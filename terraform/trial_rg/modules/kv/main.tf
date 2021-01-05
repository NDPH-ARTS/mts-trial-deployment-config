
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