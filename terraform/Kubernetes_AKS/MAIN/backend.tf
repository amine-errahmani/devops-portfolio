terraform {
  required_version = "~> 1.2"
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.15.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

