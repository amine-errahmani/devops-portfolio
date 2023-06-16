resource "azurerm_route" "route" {
  name                    = var.route_name
  resource_group_name     = var.vnet_rg_name
  route_table_name        = var.rt_name
  address_prefix          = var.address_prefix
  next_hop_type           = var.next_hop_type
  next_hop_in_ip_address  = var.next_hop_type == "VirtualAppliance" ? var.next_hop_ip : null
}
