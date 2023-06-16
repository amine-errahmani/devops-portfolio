output "rg_names" {
  value = azurerm_resource_group.resourcegroup.*.name
}
output "rg_locations" {
  value = azurerm_resource_group.resourcegroup.*.location
}

