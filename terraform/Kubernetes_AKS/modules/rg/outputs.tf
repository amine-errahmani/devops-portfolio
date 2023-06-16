output "rg_name_id" {
  value = azurerm_resource_group.rg.name
}

output "vnet_rg_name_id" {
  value = var.create_vnet ? azurerm_resource_group.k8s_vnet_rg[0].name : var.vnet_rg_name
}