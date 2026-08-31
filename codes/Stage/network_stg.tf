locals {
  # Stage resources that need network references use these keys.
  stg_network_reference_subnets = {
    stg = var.stg_subnet_name
    aca = var.stg_aca_subnet_name
  }
}

data "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.network_resource_group_name
}

data "azurerm_subnet" "stg" {
  for_each = local.stg_network_reference_subnets

  name                 = each.value
  resource_group_name  = var.network_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}
