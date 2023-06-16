locals {
  app3_ss_name = "${var.environment_short}${trim(replace(trimspace(file(".version")), ".", ""), "v")}imcm"
}

resource "azurerm_linux_virtual_machine_scale_set" "app3_vmscaleset" {
  count                           = length(var.resource_group_locations)
  name                            = "${local.app3_ss_name}${element(var.region_suffix, count.index)}"
  location                        = element(var.resource_group_locations, count.index)
  resource_group_name             = element(var.resource_group_names, count.index)
  sku                             = var.app3_VmSize
  instances                       = element(var.app3_nb_instance, count.index)
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false


  lifecycle {
    ignore_changes = [instances, data_disk]
  }

  source_image_id = element(var.app3_image_ids, count.index)

  plan {
    name = var.plan_name
    publisher = var.plan_publisher
    product = var.plan_product
  }

  computer_name_prefix = "${local.app3_ss_name}${element(var.region_suffix, count.index)}"

  os_disk {
    storage_account_type = var.disk_type
    caching                 = "ReadWrite"
    disk_size_gb            = var.os_disk_size
    disk_encryption_set_id  = element(var.encryption_set_ids, count.index)
  }

  data_disk {
    lun                     = 0
    create_option           = "FromImage"
    caching                 = "ReadWrite"
    storage_account_type    = var.disk_type
    disk_size_gb            = 500
    disk_encryption_set_id  = element(var.encryption_set_ids, count.index)
  }

  network_interface {
    name    = "${local.app3_ss_name}${element(var.region_suffix, count.index)}-vnic"
    primary = true
    enable_accelerated_networking = true

    ip_configuration {
      name      = "${local.app3_ss_name}${element(var.region_suffix, count.index)}-IPConfiguration"
      primary   = true
      subnet_id = element(data.azurerm_subnet.vendor_snet.*.id, count.index)
    }
  }

  tags = {
    Environment = var.tag_Environment
    Service     = var.tag_Service
    Solution    = var.tag_Solution
    Component   = var.tag_Component_app3
    Criticality = var.tag_Criticality_tier2
    Autoscale   = var.tag_Autoscale
    Mutability  = var.tag_Mutability
    HA          = var.tag_HA
    DR          = var.tag_DR
    RPO         = var.tag_RPO_tier2
    PCIDSS      = var.tag_PCIDSS
    Department  = var.tag_Department
    Stakeholder = var.tag_Stakeholder
    Contact     = var.tag_Contact
    monitoring  = var.tag_Monitoring
    Env_Version = var.env_version
  }
}