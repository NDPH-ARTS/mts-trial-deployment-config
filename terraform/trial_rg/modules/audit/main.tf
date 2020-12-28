resource "azurerm_storage_account" "trial_audit" {
  name                     = "${var.trial_name}audit"
  location                 = var.location
  resource_group_name      = var.rg_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Uncomment when we agree on the container name
#resource "azurerm_storage_container" "example" {
#  name                  = "tbd - container name"
#  storage_account_name  = "trial${var.trial_name}auditcontainer"
#  container_access_type = "private"
#}