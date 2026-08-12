locals {
  storage_tags = merge(
    local.common_tags,
    {
      Tag_Env                = var.environment
      Tag_DataClassification = "Confidential"
      Tag_System             = "PSYNAPS"
      Tag_Criticality        = "High"
    }
  )

  storage_blob_containers = {
    dwgetl = "st-blob-dwgetl-dev"
  }

  storage_queues = {
    dwgetl = "st-queue-dwgetl-dev"
  }

  storage_tables = {
    dwgetxreq   = "sttabledwgetldwgetxreqdev"
    dwgetxthctg = "sttabledwgetldwgetxthctgdev"
    dwgetxshtr  = "sttabledwgetldwgetxshtrdev"
    dwgpostmst  = "sttabledwgetldwgpostmstdev"
    procstatmst = "sttabledwgetlprocstatmstdev"
    exitemmst   = "sttabledwgetlexitemmstdev"
  }
}

resource "azurerm_storage_account" "this" {
  name                     = "stdwgetldev"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  public_network_access_enabled   = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true
  shared_access_key_enabled       = true
  default_to_oauth_authentication = false
  allowed_copy_scope              = "All"
  dns_endpoint_type               = "Standard"

  routing {
    choice = "MicrosoftRouting"
  }

  blob_properties {
    versioning_enabled   = false
    change_feed_enabled  = false
    last_access_time_enabled = false
  }

  tags = local.storage_tags
}

resource "azurerm_storage_container" "this" {
  for_each = local.storage_blob_containers

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_storage_queue" "this" {
  for_each = local.storage_queues

  name               = each.value
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_storage_table" "this" {
  for_each = local.storage_tables

  name               = each.value
  storage_account_id = azurerm_storage_account.this.id
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pep-blob-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-blob-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = local.storage_tags
}

resource "azurerm_private_endpoint" "storage_queue" {
  name                = "pep-queue-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-queue-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }

  tags = local.storage_tags
}

resource "azurerm_private_endpoint" "storage_table" {
  name                = "pep-table-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-table-psynaps-dev"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }

  tags = local.storage_tags
}