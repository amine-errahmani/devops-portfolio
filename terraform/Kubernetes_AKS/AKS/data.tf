data "terraform_remote_state" "aks_main" {
  backend = "azurerm"
   config = {
     storage_account_name = var.storage_account
     container_name       = var.container
     key                  = var.main_backend_key
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
  name         = data.terraform_remote_state.aks_main.outputs.aks_sp_id
  key_vault_id = data.terraform_remote_state.vault.outputs.keyvault_infra_id
  provider     = azurerm.shared
}


# data "azurerm_subnet" "private_endpoint_snet_north" {
#   name                 = var.private_endpoint_snet_name_north
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.vnet_rg_name
# }
# data "azurerm_subnet" "private_endpoint_snet_central" {
#   name                 = var.private_endpoint_snet_name_central
#   virtual_network_name = var.vnet_name_c
#   resource_group_name  = var.vnet_rg_name_c
# }

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg
  # provider            = azurerm.main
}

data "azurerm_resource_group" "cluster_rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "central_vnet" {
  name                = var.vnet_name_c
  resource_group_name = var.vnet_rg_name_c
}

data "azurerm_key_vault_key" "storage_encryption_key" {
  name         = var.storage_key_name
  key_vault_id = var.storage_encryption_vault_id  
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Policies 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
data "azurerm_policy_definition" "aks_not_allow_privileged_containers" {
  display_name = "Kubernetes cluster should not allow privileged containers"
}

data "azurerm_policy_definition" "aks_not_allow_container_privilege_escalation" {
  display_name = "Kubernetes clusters should not allow container privilege escalation"
}

data "azurerm_policy_definition" "aks_not_allow_container_capabilities" {
  display_name = "Kubernetes cluster containers should only use allowed capabilities"
}