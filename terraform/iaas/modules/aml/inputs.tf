#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Provider 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "service_sp_name" {}
variable "service_sp_pass" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  General 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
variable "environment" {}
variable "environment_short" {}
variable "resource_group_locations" {}
variable "resource_group_names" {
  type  = list(string)
}
variable "env_version" {}
variable "region_suffix" {}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  VM 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

variable "app4_image_ids" {
  type  = list(string)
}

variable "disk_type" {}
variable "disk_size" {}
variable "admin_username" {}
variable "admin_password" {}
variable "app4_VmSize" {}

variable "vendor_vnet_names" {}
variable "vendor_vnet_rgs" {}
variable "vendor_snet_names" {}

variable "app4_fileshare" {}
variable "encryption_set_ids" {
  type        = list(string)
}

// Tags
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
variable "tag_Secret_Name" {}