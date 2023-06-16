locals {
  vmname = "${var.environment_short}${trim(replace(trimspace(file(".version")), ".", ""), "v")}imui"
}

# resource "azurerm_linux_virtual_machine" "app2_b_vm" {
#   count                           = length(var.resource_group_locations)
#   name                            = "${local.vmname}01${element(var.region_suffix, count.index)}"
#   location                        = element(var.resource_group_locations, count.index)
#   resource_group_name             = element(var.resource_group_names, count.index)
#   size                            = var.app2_b_VmSize
#   admin_username                  = var.admin_username
#   admin_password                  = var.admin_password
#   network_interface_ids           = [element(azurerm_network_interface.app2_b_vnic.*.id, count.index)]
#   disable_password_authentication = false
#   computer_name                   = "${local.vmname}01${element(var.region_suffix, count.index)}"


#   source_image_id = element(data.azurerm_image.image.*.id, count.index)
  
#   plan {
#     name      = var.plan_name
#     publisher = var.plan_publisher
#     product   = var.plan_product
#   }

#   os_disk {
#     name                  = "${local.vmname}01${element(var.region_suffix, count.index)}-osDisk"
#     caching               = "ReadWrite"
#     storage_account_type  = var.disk_type
#     disk_size_gb          = var.os_disk_size
#   }

#   tags = {
#     Environment = var.environment
#     Env_Version = var.env_version
#   }
# }


resource "azurerm_virtual_machine" "app2_b_vm" {
  count                             = length(var.resource_group_locations)
  name                              = "${local.vmname}01${element(var.region_suffix, count.index)}"
  location                          = element(var.resource_group_locations, count.index)
  resource_group_name               = element(var.resource_group_names, count.index)
  vm_size                           = var.app2_b_VmSize
  network_interface_ids             = [element(azurerm_network_interface.app2_b_vnic.*.id, count.index)]
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

  storage_image_reference {
    id = element(var.app2_image_ids, count.index)
  }

  storage_os_disk {
    name              = "${local.vmname}01${element(var.region_suffix, count.index)}-osDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.disk_type
    disk_size_gb      = var.os_disk_size
  }

  os_profile {
    computer_name  = "${local.vmname}01${element(var.region_suffix, count.index)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  #  custom_data = base64encode(element(data.template_file.rh_satellite, count.index).rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # plan {
  #   name      = var.plan_name
  #   publisher = var.plan_publisher
  #   product   = var.plan_product
  # }
  
  tags = {
    Environment = var.tag_Environment
    Service     = var.tag_Service
    Solution    = var.tag_Solution
    Componenet  = var.tag_Component_batch
    Criticality = var.tag_Criticality_tier1
    Autoscale   = var.tag_Autoscale
    Mutability  = var.tag_iMutability
    HA          = var.tag_HA
    DR          = var.tag_DR
    RPO         = var.tag_RPO_tier1
    PCIDSS      = var.tag_PCIDSS
    Department  = var.tag_Department
    Stakeholder = var.tag_Stakeholder
    Contact     = var.tag_Contact
    monitoring  = var.tag_Monitoring
    Env_Version = var.env_version
    Secret_Name = var.tag_Secret_Name
  } 
}