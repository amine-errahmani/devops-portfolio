data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = "${lower(var.environment)}-${var.app_name}-${replace(var.sp_version, ".", "-")}_sp"
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
  content_type = "${var.environment} ${var.app_name} sp"
  provider     = azurerm.shared
}
resource "azurerm_role_assignment" "rg_contributor" {
  count                = length(var.resource_group_locations)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${element(var.resource_group_names, count.index)}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.id
}
resource "azurerm_role_assignment" "network_contributor" {
  count                = length(var.resource_group_locations)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${element(var.vnet_rgs, count.index)}"
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.sp.id
}
resource "azurerm_role_assignment" "gallery_rg_reader" {
  scope                = var.gallery_id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.sp.id
}
resource "azurerm_role_assignment" "encryption_set_reader" {
  for_each             = toset(var.encryption_set_ids)
  scope                = each.value
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.sp.id
}
resource "azurerm_role_assignment" "avi_rg_contributor" {
  count                = length(var.resource_group_locations)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${element(var.resource_group_names, count.index)}"
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.avigslb.id
}