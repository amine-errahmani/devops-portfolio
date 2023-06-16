terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.74.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id_dev
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  alias           = "shared"
}