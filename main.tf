terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "実際のStorageAccount名"
    container_name       = "tfstate"
    key                  = "github-actions-test.tfstate"

    use_oidc = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-github-actions-test"
  location = "Japan West"
}
