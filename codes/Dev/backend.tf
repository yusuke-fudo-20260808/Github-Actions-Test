terraform {
  backend "azurerm" {
    resource_group_name  = "rg-psynaps-prd"
    storage_account_name = "sttfstate20260810"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
