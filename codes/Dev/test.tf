resource "azurerm_resource_group" "main" {
  name     = "rg-demo-dev"
  location = var.location
}