module "rg" {
  source                    = "../modules/rg"
  resource_group_locations  = var.resource_group_locations
  environment               = var.environment
  app_name                  = var.app2_app_name
  region_suffix             = var.region_suffix
  rg_version                = data.template_file.version.rendered
}

module "sp" {
  source                    = "../modules/sp"
  subscription_id           = var.subscription_id
  subscription_id_dev       = var.subscription_id_dev
  resource_group_locations  = module.rg.rg_locations
  resource_group_names      = module.rg.rg_names
  environment               = var.environment
  app_name                  = var.app2_app_name
  vnet_rgs                  = var.vendor_vnet_rgs
  vault_state_path          = var.vault_state_path
  storage_account           = var.storage_account
  container                 = var.container
  gallery_rg                = var.gallery_rg
  gallery_id                = var.gallery_id
  sp_version                = data.template_file.version.rendered
  avi_sp                    = var.avi_sp
  encryption_set_ids        = var.encryption_set_ids
}