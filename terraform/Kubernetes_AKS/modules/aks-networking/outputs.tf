output "snet_id" {
  value = azurerm_subnet.k8s_snet.id
}

output "rt_name" {
  value = azurerm_route_table.k8s_rt.name
}