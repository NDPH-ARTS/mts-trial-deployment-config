
# Service application generic module that loads a docker image with mounting
# UNIQUE
resource "azurerm_app_service" "generic_service_with_storage_mount" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_image}:${var.docker_image_tag}"
    always_on        = true
  }

  identity {
    type = "SystemAssigned"
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

  app_settings = var.settings

  dynamic "storage_account" {
    for_each = var.storage_account
    content {
      name         = setting.value["name"]
      type         = setting.value["type"]
      account_name = setting.value["account_name"]
      share_name   = setting.value["share_name"]
      access_key   = setting.value["access_key"]
      mount_path   = setting.value["mount_path"]
    }
  }
}

# count = 0, if this is the gateway and no private endpoint is needed
module "private_endpoint" {
  count            = var.enable_private_endpoint == true ? 1 : 0
  source           = "../privateendpoint"
  trial_name       = var.trial_name
  rg_name          = var.rg_name
  resource_id      = azurerm_app_service.generic_service_with_storage_mount.id
  subnet_id        = var.subnet_id
  subresource_name = "sites"
  application      = var.app_name
  dns_zone_id      = var.dns_zone_id

  depends_on = [
    azurerm_app_service.generic_service_with_storage_mount,
  ]
}