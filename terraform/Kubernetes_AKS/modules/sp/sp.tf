data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = "${var.cluster_name}-sp"
}

resource "azuread_service_principal" "sp" {
  application_id  = azuread_application.app.application_id
  owners          = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "sp_pass" {
  service_principal_id = azuread_service_principal.sp.id
}

resource "azurerm_key_vault_secret" "sp_secret" {
  name         = azuread_application.app.application_id
  value        = azuread_service_principal_password.sp_pass.value
  key_vault_id = data.terraform_remote_state.vault.outputs.keyvault_infra_id
  content_type = "${var.environment} ${var.cluster_name} sp"
  provider     = azurerm.shared
}
resource "azurerm_role_assignment" "rg_owner" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "rg_policy_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.vnet_rg_name}"
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "network_contributor_c" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.vnet_rg_name_c}"
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.sp.id
}

# resource "azurerm_role_assignment" "avi_rg_contributor" {
#   scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"
#   role_definition_name = "Contributor"
#   principal_id         = data.azuread_service_principal.avigslb.id
# }
resource "azurerm_role_assignment" "acr_contributor" {
  scope                            = data.azurerm_resource_group.acr_rg.id
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.sp.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "keyvault_Contributor" {
  scope                             = var.key_vault_id
  role_definition_name              = "Contributor"
  principal_id                      = azuread_service_principal.sp.id
  skip_service_principal_aad_check  = true
}

resource "azurerm_role_assignment" "encryptionset_reader" {
  scope                             = var.encryption_set_id
  role_definition_name              = "Reader"
  principal_id                      = azuread_service_principal.sp.id
  skip_service_principal_aad_check  = true
}


resource "azurerm_key_vault_access_policy" "storage_encryption_keys_access" {
  key_vault_id        = var.key_vault_id
  tenant_id           = var.tenant_id
  object_id           = azuread_service_principal.sp.id
  key_permissions     = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions  = ["Get"]
}

resource "azurerm_role_assignment" "sub_reader" {
  scope                             = data.azurerm_subscription.primary.id
  role_definition_name              = "Reader"
  principal_id                      = azuread_service_principal.sp.id
  skip_service_principal_aad_check  = true
}

resource "azurerm_role_assignment" "msi_contributor" {
  scope                             = data.azurerm_subscription.primary.id
  role_definition_name              = "Managed Identity Contributor"
  principal_id                      = azuread_service_principal.sp.id
  skip_service_principal_aad_check  = true
}

resource "azurerm_role_assignment" "msi_operator" {
  scope                             = data.azurerm_subscription.primary.id
  role_definition_name              = "Managed Identity Operator"
  principal_id                      = azuread_service_principal.sp.id
  skip_service_principal_aad_check  = true
}

resource "azurerm_role_assignment" "sub_access_admin" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "sub_storage_accaount_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "sub_network_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.sp.id
}
