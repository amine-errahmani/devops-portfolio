variable "subscription_id" {}
variable "subscription_id_dev" {}
variable "storage_account" {}
variable "container" {}

variable "environment" {}
variable "app_name" {}
variable "sp_version" {}
variable "vnet_rgs" {
  type  = list(string)
}
variable "resource_group_locations" {
  type  = list(string)
}
variable "resource_group_names" {
  type  = list(string)
}
variable "vault_state_path" {}

variable "gallery_rg" {}
variable "gallery_id" {}

variable "avi_sp" {}

variable "encryption_set_ids" {
  type        = list(string)
}