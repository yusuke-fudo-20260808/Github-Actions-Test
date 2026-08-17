locals {
  storage_tags = merge(
    local.common_tags,
    {
      Env                = var.environment
      DataClassification = "Confidential"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )

  storage_blob_containers = {
    dwgetl = "st-blob-dwgetl-dev"
  }

  storage_queues = {
    dwgetl = "st-queue-dwgetl-dev"
  }

  # Azure Table Storage names allow only alphanumeric characters.
  storage_tables = {
    dwgetxreq   = "sttabledwgetldwgetxreqdev"
    dwgetxthctg = "sttabledwgetldwgetxthctgdev"
    dwgetxshtr  = "sttabledwgetldwgetxshtrdev"
    dwgpostmst  = "sttabledwgetldwgpostmstdev"
    procstatmst = "sttabledwgetlprocstatmstdev"
    exitemmst   = "sttabledwgetlexitemmstdev"
  }
}

resource "azurerm_storage_account" "this_private" {
  name                            = "teststorage20260817"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  public_network_access_enabled   = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true
  shared_access_key_enabled       = true
  default_to_oauth_authentication = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = local.storage_tags
}

resource "azurerm_storage_container" "this_private" {
  for_each = local.storage_blob_containers

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this_private.id
  container_access_type = "private"
}

resource "azurerm_storage_queue" "this_private" {
  for_each = local.storage_queues

  name               = each.value
  storage_account_id = azurerm_storage_account.this_private.id
}

resource "azurerm_storage_table" "this_private" {
  for_each = local.storage_tables

  name               = each.value
  storage_account_id = azurerm_storage_account.this_private.id
  depends_on = [
    azurerm_private_endpoint.storage,
  azurerm_private_dns_zone_virtual_network_link.storage_table]
}

resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = local.storage_tags
}

resource "azurerm_private_dns_zone" "storage_queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = local.storage_tags
}

resource "azurerm_private_dns_zone" "storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = local.storage_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "pdnslink-blob-psynaps-dev"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.storage_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue" {
  name                  = "pdnslink-queue-psynaps-dev"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_queue.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.storage_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_table" {
  name                  = "pdnslink-table-psynaps-dev"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.storage_tags
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pep-blob-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-blob-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this_private.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-blob-psynaps-dev"
    private_ip_address = "10.14.167.13"
    subresource_name   = "blob"
    member_name        = "blob"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob.id]
  }
}

resource "azurerm_private_endpoint" "storage_queue" {
  name                = "pep-queue-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-queue-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this_private.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-queue-psynaps-dev"
    private_ip_address = "10.14.167.14"
    subresource_name   = "queue"
    member_name        = "queue"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-queue"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_queue.id]
  }
}

resource "azurerm_private_endpoint" "storage_table" {
  name                = "pep-table-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-table-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this_private.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-table-psynaps-dev"
    private_ip_address = "10.14.167.15"
    subresource_name   = "table"
    member_name        = "table"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-table"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_table.id]
  }
}
