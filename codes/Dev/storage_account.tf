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

resource "azurerm_storage_account" "this" {
  name                            = "stdwgetldev"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  public_network_access_enabled   = true
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true
  shared_access_key_enabled       = true
  default_to_oauth_authentication = false

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