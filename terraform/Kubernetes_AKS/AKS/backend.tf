terraform {
  required_version = "~> 1.2"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.15.0"
    }
  }
}

provider "azurerm" {
  client_id     = data.terraform_remote_state.aks_main.outputs.aks_sp_id
  client_secret = data.azurerm_key_vault_secret.service_sp.value
  skip_provider_registration = true
  features {}
}

provider "azurerm" {
  subscription_id = var.subscription_id_dev
  skip_provider_registration = true
  features {}
  alias           = "shared"
}


# provider "azurerm" {
#   skip_provider_registration = true
#   features {}

#   client_id     = ""
#   client_secret = ""
  
#   alias           = "main"
# }
