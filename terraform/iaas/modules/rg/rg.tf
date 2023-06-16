resource "azurerm_resource_group" "resourcegroup" {
  count    = length(var.resource_group_locations)
  location = element(var.resource_group_locations, count.index)
  name     = "${replace(var.rg_version, ".", "-")}-${var.environment}-${var.app_name}-rg-${element(var.region_suffix, count.index)}"

  lifecycle {
    ignore_changes = [tags]
  }
}
