terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.74.0"
    }
  }
}

provider "azurerm" {
  client_id     = var.service_sp_name
  client_secret = var.service_sp_pass
  features {}
}