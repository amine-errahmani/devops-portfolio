data "template_file" "version" {
  template = file(".version")
}

data "terraform_remote_state" "app2_main" {
  backend = "azurerm"
   config = {
     storage_account_name = var.storage_account
     container_name       = var.container
     key                  = "${upper(var.environment)}/vendor/MAIN_app2/${data.template_file.version.rendered}/terraform.tfstate"
   }
}

data "terraform_remote_state" "vault" {
  backend = "azurerm"
  config  = {
    storage_account_name  = var.storage_account
    container_name        = var.container
    key                   = "${var.vault_state_path}/terraform.tfstate"
  }
}

data "azurerm_key_vault_secret" "service_sp" {
  name         = data.terraform_remote_state.app2_main.outputs.app2_service_sp_name
  key_vault_id = data.terraform_remote_state.vault.outputs.keyvault_infra_id
  provider     = azurerm.shared
}

locals {
  json_data = jsondecode(file("../../jenkins/config/jenkinsfile.json"))
}

data "azurerm_shared_image_version" "app2_image_version" {
  count               = length(var.resource_group_locations)
  name                = var.app2_image_version
  image_name          = element(var.app2_image_names, count.index)
  gallery_name        = var.gallery_name
  resource_group_name = var.gallery_rg
  provider            = azurerm.gallery
}