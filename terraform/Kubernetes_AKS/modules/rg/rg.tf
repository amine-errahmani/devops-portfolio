resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = var.rg_name

  lifecycle {
    ignore_changes = [tags]
  }
}

# temp vnet rg
resource "azurerm_resource_group" "k8s_vnet_rg" {
  count    = var.create_vnet ? 1 : 0
  name     = var.vnet_rg_name
  location = var.rg_location
}
