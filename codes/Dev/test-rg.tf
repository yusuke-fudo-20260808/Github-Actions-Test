resource "azurerm_resource_group" "rg" {
  name     = "rg-test-japaneast"
  location = "Japan East"

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}