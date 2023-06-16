resource "azurerm_network_security_group" "k8s_nsg" {
  name                  = var.nsg_name
  location              = var.rg_location
  resource_group_name   = var.vnet_rg_name
  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_network_security_rule" "k8s_inbound" {
  name                        = "Allow_Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.vnet_rg_name
  network_security_group_name = azurerm_network_security_group.k8s_nsg.name
}

resource "azurerm_network_security_rule" "k8s_outbound" {
  name                        = "Allow_Outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.vnet_rg_name
  network_security_group_name = azurerm_network_security_group.k8s_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "k8s_nsg_snet_link" {
  subnet_id                 = azurerm_subnet.k8s_snet.id
  network_security_group_id = azurerm_network_security_group.k8s_nsg.id
}

