resource "azurerm_route_table" "k8s_rt" {
  name                          = var.rt_name
  location                      = var.rg_location
  resource_group_name           = var.vnet_rg_name
  disable_bgp_route_propagation = false
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet_route_table_association" "rt_snet_link" {
  subnet_id      = azurerm_subnet.k8s_snet.id
  route_table_id = azurerm_route_table.k8s_rt.id
}