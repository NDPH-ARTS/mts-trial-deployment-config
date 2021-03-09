
# Service application module that loads a docker image and mounts to storage account
# UNIQUE
resource "azurerm_app_service" "init_service" {
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

  storage_account {
    name         = var.storage_account_name
    type         = var.storage_account_type
    account_name = var.storage_account_account_name
    share_name   = var.storage_account_share_name
    access_key   = var.storage_account_access_key
    mount_path   = var.storage_account_mount_path
  }

}