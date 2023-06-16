terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
  alias           = "shared"
}

provider "azurerm" {
  subscription_id = var.subscription_id_gallery
  features {}
  alias           = "gallery"
}