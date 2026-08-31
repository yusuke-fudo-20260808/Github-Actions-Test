locals {
  aca_tags = merge(
    local.common_tags,
    {
      Env                = var.environment
      DataClassification = "Confidential"
      System             = "PSYNAPS"
      Criticality        = "High"
    }
  )

  aca_private_dns_zone_name = "privatelink.${lower(replace(var.location, " ", ""))}.azurecontainerapps.io"
  aca_private_endpoint_ip   = "10.14.167.18"

  dwfpdf_container_name = "ca-dwfpdf-psynaps-dev-01"
}

# ========================================================================
# 1. Container Apps Environment リソース
# ========================================================================

resource "azurerm_container_app_environment" "aca" {
  name                     = "caenv-psynaps-dev"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  public_network_access    = "Disabled"
  infrastructure_subnet_id = azurerm_subnet.dev["aca"].id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  tags = local.aca_tags
}

# ========================================================================
# 2. マネージドID リソース
# ========================================================================

resource "azurerm_user_assigned_identity" "dwfpdf" {
  name                = "id-ca-dwfpdf-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.aca_tags
}

# ========================================================================
# 3. プライベートDNSゾーン リソース
# ========================================================================

resource "azurerm_private_dns_zone" "container_apps" {
  name                = local.aca_private_dns_zone_name
  resource_group_name = var.resource_group_name_prd

  tags = local.aca_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_apps" {
  name                  = "pdnslink-ca-psynaps-dev"
  resource_group_name   = var.resource_group_name_prd
  private_dns_zone_name = azurerm_private_dns_zone.container_apps.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false

  tags = local.aca_tags
}

# ========================================================================
# 3. プライベートエンドポイント リソース
# ========================================================================

resource "azurerm_private_endpoint" "aca" {
  name                = "pep-ca-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.dev["dev"].id

  private_service_connection {
    name                           = "psc-ca-psynaps-dev"
    private_connection_resource_id = azurerm_container_app_environment.aca.id
    subresource_names              = ["managedEnvironments"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "prip-ca-psynaps-dev"
    private_ip_address = local.aca_private_endpoint_ip
    subresource_name   = "managedEnvironments"
    member_name        = "managedEnvironments"
  }

  private_dns_zone_group {
    name                 = "pdnsgroup-ca-psynaps-dev"
    private_dns_zone_ids = [azurerm_private_dns_zone.container_apps.id]
  }

  tags = local.aca_tags
}

# ========================================================================
# 4. DWF/PDF コンテナアプリ リソース
# ========================================================================

resource "azurerm_container_app" "dwfpdf" {
  name                         = "ca-dwfpdf-psynaps-dev"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.aca.id
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  depends_on = [azurerm_role_assignment.dwfpdf_acr_pull]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.dwfpdf.id]
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = local.dwfpdf_container_name
      image  = "${azurerm_container_registry.aca.login_server}/nginx:latest"
      cpu    = 1.0
      memory = "2Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = azurerm_container_registry.aca.login_server
    identity = azurerm_user_assigned_identity.dwfpdf.id
  }

  tags = local.aca_tags
}

# ========================================================================
# 5. マネージドID設定
# ========================================================================

resource "azurerm_role_assignment" "dwfpdf_acr_pull" {
  scope                = azurerm_container_registry.aca.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.dwfpdf.principal_id
}
