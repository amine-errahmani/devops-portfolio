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
