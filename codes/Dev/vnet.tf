resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    "10.0.0.0/16"
  ]

  tags = {
    Environment = var.environment
  }
}
