locals {
  bastion_tags = merge(
    local.common_tags,
    {
      Env                = var.environment
      DataClassification = "Internal"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-psynaps-prd"
  location            = var.location
  resource_group_name = "rg-psynaps-prd"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.bastion_tags
}

resource "azurerm_bastion_host" "this" {
  name                = "bastion-psynaps-prd"
  location            = var.location
  resource_group_name = "rg-psynaps-prd"
  sku                 = "Standard"
  scale_units         = 2

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = local.bastion_tags
}