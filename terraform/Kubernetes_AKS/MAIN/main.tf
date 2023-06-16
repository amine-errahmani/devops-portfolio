module "rg" {
  source      = "../modules/rg"
  rg_location   = var.rg_location
  rg_name       = var.rg_name
  vnet_rg_name  = var.vnet_rg_name
  create_vnet   = var.create_vnet
}

module "sp" {
  source              = "../modules/sp"
  subscription_id     = var.subscription_id
  subscription_id_dev = var.subscription_id_dev
  # client_id_dev       = var.client_id_dev
  tenant_id           = var.tenant_id
  # client_secret_dev   = var.client_secret_dev
  rg_location         = var.rg_location
  rg_name             = module.rg.rg_name_id
  environment         = var.environment
  cluster_name        = var.cluster_name
  vnet_rg_name        = module.rg.vnet_rg_name_id 
  vnet_rg_name_c      = var.vnet_rg_name_c
  vault_state_path    = var.vault_state_path
  storage_account     = var.storage_account
  container           = var.container
  avi_sp              = var.avi_sp
  acr_rg              = var.acr_rg
  key_vault_id        = var.storage_encryption_vault_id
  encryption_set_id   = var.encryption_set_id
}