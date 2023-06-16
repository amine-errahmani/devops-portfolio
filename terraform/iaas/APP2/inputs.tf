# ---------------------------
# General
# ---------------------------
variable "subscription_id" {} # defined as ENV Variable
variable "subscription_id_dev" {} # defined as ENV Variable


# ---------------------------
# Resource group
# ---------------------------
variable "resource_group_locations" {
  type        = list(string)
}
variable "environment" {}
variable "environment_short" {}
variable "app_name" {}
variable "app3_app_name" {}
variable "app4_app_name" {}
variable "app2_app_name" {}
variable "app1_app_name" {}
variable "region_suffix" {}

# ---------------------------
# Common
# ---------------------------
variable "storage_account" {}
variable "container" {}
variable "vault_state_path" {}

variable "plan_name" {}
variable "plan_publisher" {}
variable "plan_product" {}

variable "disk_type" {}
variable "os_disk_size" {}

variable "vendor_vnet_names" {}
variable "vendor_vnet_rgs" {}
variable "vendor_snet_names" {}

variable "admin_username" {}

variable "gallery_name" {}
variable "gallery_rg" {}
variable "gallery_id" {}

variable "subscription_id_gallery" {}

variable "avi_sp" {}

variable "encryption_set_ids" {
  type        = list(string)
}

// tags
variable "tag_Environment" {}
variable "tag_Service" {}
variable "tag_Solution" {}
variable "tag_Component_app3" {}
variable "tag_Component_app1" {}
variable "tag_Component_app2" {}
variable "tag_Component_batch" {}
variable "tag_Component_app4" {}
variable "tag_Criticality_tier1" {}
variable "tag_Criticality_tier2" {}
variable "tag_Criticality_tier3" {}
variable "tag_Autoscale" {}
variable "tag_iMutability" {}
variable "tag_Mutability" {}
variable "tag_HA" {}
variable "tag_DR" {}
variable "tag_RPO_tier1" {}
variable "tag_RPO_tier2" {}
variable "tag_RPO_tier3" {}
variable "tag_PCIDSS" {}
variable "tag_Department" {}
variable "tag_Stakeholder" {}
variable "tag_Contact" {}
variable "tag_Monitoring" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  app3 VM
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "app3_VmSize" {}

variable "app3_nb_instance" {}
# variable "neo4j_nb_instance" {}
# variable "solr_nb_instance" {}

variable "app3_image_names" {
  type        = list(string)
}
variable "app3_image_version" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# app4 VM
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "app4_VmSize" {}

variable "app4_data_disk_size" {}

variable "app4_fileshare" {}

variable "app4_image_names" {
  type        = list(string)
}
variable "app4_image_version" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  app2 SS & VMs 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "vm_size_app" {}
variable "app2_b_VmSize" {}

variable "nb_instance" {}
variable "nb_instance_app1" {}

variable "app2_image_names" {
  type        = list(string)
}
variable "app2_image_version" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# app1 SS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "vm_size_app1" {}

variable "app1_image_names" {
  type        = list(string)
}
variable "app1_image_version" {}