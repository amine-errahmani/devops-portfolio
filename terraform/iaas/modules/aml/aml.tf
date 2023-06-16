locals {
  vmname = "${var.environment_short}${trim(replace(trimspace(file(".version")), ".", ""), "v")}imsr"
}


resource "azurerm_virtual_machine" "app4_vm" {
  count                             = length(var.resource_group_locations)
  name                              = "${local.vmname}01${element(var.region_suffix, count.index)}"
  location                          = element(var.resource_group_locations, count.index)
  resource_group_name               = element(var.resource_group_names, count.index)
  vm_size                           = var.app4_VmSize
  network_interface_ids             = [element(azurerm_network_interface.app4_vnic.*.id, count.index)]
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

  storage_image_reference {
    id = element(var.app4_image_ids, count.index)
  }

  storage_os_disk {
    name              = "${local.vmname}01${element(var.region_suffix, count.index)}-osDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.disk_type
  }

  os_profile {
    computer_name  = "${local.vmname}01${element(var.region_suffix, count.index)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    # custom_data    = base64encode(data.template_file.postconf.rendered)
  }
  
  os_profile_windows_config {
    timezone  = "Arabian Standard Time"
    enable_automatic_upgrades = false
    provision_vm_agent        = true
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = data.template_file.auto_logon.rendered
    }
    #additional_unattend_config {
    #  pass         = "oobeSystem"
    #  component    = "Microsoft-Windows-Shell-Setup"
    #  setting_name = "FirstLogonCommands"
    #  content      = file("${path.module}/templates/tpl.first_logon_commands.xml")
    #}
  }

  tags = {
    Environment = var.tag_Environment
    Service     = var.tag_Service
    Solution    = var.tag_Solution
    Componenet  = var.tag_Component_app4
    Criticality = var.tag_Criticality_tier3
    Autoscale   = var.tag_Autoscale
    Mutability  = var.tag_Mutability
    HA          = var.tag_HA
    DR          = var.tag_DR
    RPO         = var.tag_RPO_tier3
    PCIDSS      = var.tag_PCIDSS
    Department  = var.tag_Department
    Stakeholder = var.tag_Stakeholder
    Contact     = var.tag_Contact
    monitoring  = var.tag_Monitoring
    Env_Version = var.env_version
    Secret_Name = var.tag_Secret_Name
  }
}