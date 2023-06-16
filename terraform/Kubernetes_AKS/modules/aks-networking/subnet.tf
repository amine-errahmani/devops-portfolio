resource "azurerm_virtual_network" "k8s_vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  address_space       = var.vnet_cidr
  location            = var.rg_location
  resource_group_name = var.vnet_rg_name
}

resource "azurerm_subnet" "k8s_snet" {
    name                    = var.snet_name
    virtual_network_name    = var.create_vnet ? azurerm_virtual_network.k8s_vnet[0].name : var.vnet_name
    resource_group_name     = var.vnet_rg_name
    address_prefixes        = var.cidr
    
    enforce_private_link_endpoint_network_policies = true
}