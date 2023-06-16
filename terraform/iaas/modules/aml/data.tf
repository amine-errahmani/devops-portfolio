data "azurerm_virtual_network" "vendor_vnet" {
  count               = length(var.resource_group_locations)
  name                = element(var.vendor_vnet_names, count.index)
  resource_group_name = element(var.vendor_vnet_rgs, count.index)
}


data "azurerm_subnet" "vendor_snet" {
  count                = length(var.resource_group_locations)
  name                 = element(var.vendor_snet_names, count.index)
  virtual_network_name = element(data.azurerm_virtual_network.vendor_vnet.*.name, count.index)
  resource_group_name  = element(var.vendor_vnet_rgs, count.index)
}

data "template_file" "taskImport" {
  template = "${file("../../powershell/app4_task_import.ps1")}"
}

data "template_file" "fileshare" {
  template = "${file("../../powershell/app4_fileshare.ps1")}"
}
  
data "template_file" "auto_logon" {
  template = "${file("${path.module}/templates/tpl.auto_logon.xml")}"
  vars = {
    admin_username = "${var.admin_username}"
    admin_password = "${replace(var.admin_password,"&","&amp;")}"
  }
}
data "template_file" "postconf" {
  template = "${file("../../powershell/app4_postconf.ps1")}"
}