resource "random_password" "app2_admin_pass" {
  length           = 24
  special          = true
  override_special = "`@"
}

resource "random_id" "secret_id" {
  byte_length = 2
}

resource "azurerm_key_vault_secret" "app2_secret" {
  name         = "${replace(data.template_file.version.rendered, ".", "-")}-${var.environment}-${var.app2_app_name}-admin-pass-${random_id.secret_id.hex}"
  value        = random_password.app2_admin_pass.result
  key_vault_id = data.terraform_remote_state.vault.outputs.keyvault_infra_id
  content_type = "${var.environment} ${var.app2_app_name} admin_pass"
  provider     = azurerm.shared
}