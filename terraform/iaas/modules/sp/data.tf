
data "terraform_remote_state" "vault" {
  backend = "azurerm"
  config  = {
    storage_account_name  = var.storage_account
    container_name        = var.container
    key                   = "${var.vault_state_path}/terraform.tfstate"
  }
}

data "azuread_service_principal" "avigslb"{
  display_name= var.avi_sp
}