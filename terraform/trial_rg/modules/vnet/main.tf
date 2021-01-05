# a vnet and a single sibnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.trial_name}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "integrationsubnet" {
  name                 = "main-subnet-${var.trial_name}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = [ "Microsoft.KeyVault", "Microsoft.Sql" ]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}