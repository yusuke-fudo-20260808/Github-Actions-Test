locals {
  test_rg_location = var.location

  test_rg_tags = merge(
    local.common_tags,
    {
      Environment = "test"
      ManagedBy   = "Terraform"
    }
  )
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-test-dev"
  location = local.test_rg_location
  tags     = local.test_rg_tags
}

resource "azurerm_resource_group" "stg" {
  name     = "rg-test-stg"
  location = local.test_rg_location
  tags     = local.test_rg_tags
}

resource "azurerm_resource_group" "prd" {
  name     = "rg-test-prd"
  location = local.test_rg_location
  tags     = local.test_rg_tags
}