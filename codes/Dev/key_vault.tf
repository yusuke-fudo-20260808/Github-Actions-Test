data "azurerm_client_config" "current" {}

locals {
  key_vault_tags = merge(
    local.common_tags,
    {
      Env                = var.environment
      DataClassification = "Confidential"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )

  key_vault_private_endpoint_ip = "10.14.167.11"
}

resource "azurerm_key_vault" "this" {
  name                = "kv-secret-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = false

  # Public network access is disabled; access is only via private endpoint.
  network_acls {
    bypass         = "None"
    default_action = "Deny"
  }

  tags = local.key_vault_tags
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name_prd

  tags = local.key_vault_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "pdnslink-kv-psynaps-prd"
  resource_group_name   = var.resource_group_name_prd
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.key_vault_tags
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pep-kv-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-kv-psynaps-dev"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-kv-psynaps-dev"
    private_ip_address = local.key_vault_private_endpoint_ip
    subresource_name   = "vault"
    member_name        = "default"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-kv-psynaps-dev"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

  tags = local.key_vault_tags
}
