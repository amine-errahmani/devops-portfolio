# resource "azurerm_network_interface" "app3_solr_vnic" {
#   count               = length(var.resource_group_locations)
#   name                = "${local.vmname_solr}01${element(var.region_suffix, count.index)}-vnic"
#   location            = element(var.resource_group_locations, count.index)
#   resource_group_name = element(var.resource_group_names, count.index)

#   ip_configuration {
#     name                          = "${local.vmname_solr}01${element(var.region_suffix, count.index)}-IPConfiguration"
#     subnet_id                     = element(data.azurerm_subnet.vendor_snet.*.id, count.index)
#     private_ip_address_allocation = "dynamic"
#   }
#   tags = {
#     Environment = var.environment
#     Env_Version = var.env_version
#   }
# }

# resource "azurerm_network_interface" "app3_kafka_vnic" {
#   count               = length(var.resource_group_locations)
#   name                = "${local.vmname_kafka}01${element(var.region_suffix, count.index)}-vnic"
#   location            = element(var.resource_group_locations, count.index)
#   resource_group_name = element(var.resource_group_names, count.index)

#   ip_configuration {
#     name                          = "${local.vmname_kafka}01${element(var.region_suffix, count.index)}-IPConfiguration"
#     subnet_id                     = element(data.azurerm_subnet.vendor_snet.*.id, count.index)
#     private_ip_address_allocation = "dynamic"
#   }
#   tags = {
#     Environment = var.environment
#     Env_Version = var.env_version
#   }
# }

# resource "azurerm_network_interface" "app3_neo4j_vnic" {
#   count               = length(var.resource_group_locations)
#   name                = "${local.vmname_neo4j}01${element(var.region_suffix, count.index)}-vnic"
#   location            = element(var.resource_group_locations, count.index)
#   resource_group_name = element(var.resource_group_names, count.index)

#   ip_configuration {
#     name                          = "${local.vmname_neo4j}01${element(var.region_suffix, count.index)}-IPConfiguration"
#     subnet_id                     = element(data.azurerm_subnet.vendor_snet.*.id, count.index)
#     private_ip_address_allocation = "dynamic"
#   }
#   tags = {
#     Environment = var.environment
#     Env_Version = var.env_version
#   }
# }