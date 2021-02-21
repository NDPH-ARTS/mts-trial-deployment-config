
# Container group module for init service that loads a docker image in a container instance

resource "azurerm_container_group" "init_service" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.rg_name
  ip_address_type     = "public"
  dns_name_label      = "temp1234567" #remove this one go private
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name              = var.app_name
    image             = "${var.docker_image}:${var.docker_image_tag}"
    cpu               = "1"
    memory            = "1.5"

    ports {
      port = 8080
      protocol = "TCP"
    }

    environment_variables = var.settings
  }
}