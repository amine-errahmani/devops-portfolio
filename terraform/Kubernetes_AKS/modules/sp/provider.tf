terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.15.0"
    }
  }
}

provider "azurerm" {
  # subscription_id = var.subscription_id_dev
  # client_id       = var.client_id_dev
  # client_secret   = var.client_secret_dev
  # tenant_id       = var.tenant_id_dev
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  alias           = "shared"
}