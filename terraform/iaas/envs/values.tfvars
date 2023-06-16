#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Main 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
environment = "prd"
environment_short = "p"
app_name    = "vendor"

app3_app_name = "vendor-app3"
app4_app_name = "vendor-app4"
app2_app_name = "vendor-app2"
app1_app_name = "vendor-app1"

storage_account     = ""
container           = ""
vault_state_path    = ""

//VNETS
vendor_vnet_names  = ["", ""]
vendor_vnet_rgs    = ["", ""]    

//Subnets
vendor_snet_names  = ["", ""]

resource_group_locations = ["UAE North", "UAE Central"]
# deactivate central deployments
#resource_group_locations = ["UAE North"] 
region_suffix            = ["n", "c"]

gallery_name    = ""
gallery_rg      = ""
gallery_id      = ""

subscription_id_gallery = ""

avi_sp  = ""

//Tags
tag_Environment         = "Production"
tag_Service             = ""
tag_Solution            = ""
tag_Component_app3       = ""
tag_Component_app1   = ""
tag_Component_app2    = ""
tag_Component_batch     = ""
tag_Component_app4       = ""
tag_Criticality_tier1   = "Tier 1"
tag_Criticality_tier2   = "Tier 2"
tag_Criticality_tier3   = "Tier 3"
tag_Autoscale           = "No"
tag_iMutability         = "Immutable"
tag_Mutability          = "Mutable"
tag_HA                  = "Yes"
tag_DR                  = "Active/Active"
tag_RPO_tier1           = "< 15 minutes"
tag_RPO_tier2           = "< 1 hour"
tag_RPO_tier3           = "< 8 hours"
tag_PCIDSS              = "No"
tag_Department          = ""
tag_Stakeholder         = ""
tag_Contact             = ""
tag_Monitoring          = "true"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  RHEL golden image                                        
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
plan_name       = "rhel-lvm79-gen2"
plan_publisher  = "redhat"
plan_product    = "rhel-byos"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  app2 + app2 app1 SS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
admin_username          = "admin"
vm_size_app             = "Standard_DS4_v2"
vm_size_app1            = "Standard_DS3_v2"
nb_instance             = ["3", "2"]
nb_instance_app1        = ["2", "1"]
disk_type               = "Standard_LRS"
os_disk_size            = "128"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  VMs
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

app2_b_VmSize = "Standard_DS4_v2"

app3_VmSize      = "Standard_DS3_v2"

app3_nb_instance   = ["3", "3"]

app4_VmSize          = "Standard_DS3_v2"
app4_data_disk_size  = "128" #size in gb

app4_fileshare = ""

encryption_set_ids = [""]

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  images
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

app3_image_names = ["", ""]
app3_image_version = "latest"
app2_image_names = ["", ""]
app2_image_version = "latest"
app1_image_names = ["", ""]
app1_image_version = "latest"
app4_image_names = ["", ""]
app4_image_version = "latest"
