resource "azurerm_network_interface" "app2_b_vnic" {
  count                         = length(var.resource_group_locations)
  name                          = "${local.vmname}01${element(var.region_suffix, count.index)}-vnic"
  location                      = element(var.resource_group_locations, count.index)
  resource_group_name           = element(var.resource_group_names, count.index)
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.vmname}01${element(var.region_suffix, count.index)}-IPConfiguration"
    subnet_id                     = element(data.azurerm_subnet.vendor_snet.*.id, count.index)
    private_ip_address_allocation = "dynamic"
  }
  tags = {
    Environment = var.environment
    Env_Version = var.env_version
  }
}
