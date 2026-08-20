locals {
  acr_tags = merge(
    local.common_tags,
    {
      Env                = var.environment
      DataClassification = "Confidential"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )

  acr_stg_tags = merge(
    local.common_tags,
    {
      Env                = "Staging"
      DataClassification = "Confidential"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )
}

# ========================================================================
# 1. Azure Container Registry リソース
# ========================================================================

resource "azurerm_container_registry" "aca" {
  name                = "acrpsynapsdev"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  data_endpoint_enabled         = false
  zone_redundancy_enabled       = false

  network_rule_bypass_option = "AzureServices"

  tags = local.acr_tags
}

resource "azurerm_container_registry" "aca_stg" {
  name                = "acrpsynapsstg"
  resource_group_name = var.resource_group_name_stg
  location            = var.location
  sku                 = "Premium"

  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  data_endpoint_enabled         = false
  zone_redundancy_enabled       = false

  network_rule_bypass_option = "AzureServices"

  tags = local.acr_stg_tags
}

# ========================================================================
# 2. Private DNSゾーン リソース
# ========================================================================

resource "azurerm_private_dns_zone" "container_registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = local.acr_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry" {
  name                  = "pdnslink-acr-psynaps-dev"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_registry.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.acr_tags
}

# ========================================================================
# 3. プライベートエンドポイント リソース
# ========================================================================

resource "azurerm_private_endpoint" "aca_registry" {
  name                = "pep-acr-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-acr-psynaps-dev"
    private_connection_resource_id = azurerm_container_registry.aca.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-acr-psynaps-dev"
    private_ip_address = "10.14.167.12"
    subresource_name   = "registry"
    member_name        = "registry"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-acr-psynaps-dev"
    private_dns_zone_ids = [azurerm_private_dns_zone.container_registry.id]
  }

  tags = local.acr_tags
}

resource "azurerm_private_endpoint" "aca_registry_stg" {
  name                = "pep-acr-psynaps-stg"
  location            = var.location
  resource_group_name = var.resource_group_name_stg
  subnet_id           = azurerm_subnet.stg["stg"].id

  private_service_connection {
    name                           = "psc-acr-psynaps-stg"
    private_connection_resource_id = azurerm_container_registry.aca_stg.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-acr-psynaps-stg"
    private_ip_address = "10.14.166.12"
    subresource_name   = "registry"
    member_name        = "registry"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-acr-psynaps-stg"
    private_dns_zone_ids = [azurerm_private_dns_zone.container_registry.id]
  }

  tags = local.acr_stg_tags
}


