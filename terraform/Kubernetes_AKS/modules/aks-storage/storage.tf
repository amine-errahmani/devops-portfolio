locals {
  storage_account_name = "${replace(var.cluster_name, "-", "")}sa"
}
resource "azurerm_storage_account" "aks_storage_account" {
  name                      = local.storage_account_name
  resource_group_name       = var.node_rg
  location                  = var.rg_location
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  account_kind              = "StorageV2"

  network_rules {
      default_action     = "Deny"
      bypass             = ["Metrics", "Logging", "AzureServices"]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_managed_identity.id]
  }

  customer_managed_key {
    key_vault_key_id          = var.key_vault_key_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_managed_identity.id
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [azurerm_key_vault_access_policy.storage]
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id        = var.key_vault_id
  tenant_id           = var.tenant_id
  object_id           = azurerm_user_assigned_identity.storage_managed_identity.principal_id
  key_permissions     = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions  = ["Get"]
}

resource "azurerm_user_assigned_identity" "storage_managed_identity" {
  name                = "${var.cluster_name}-storage"
  resource_group_name = var.node_rg
  location            = var.rg_location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "aks_storage_private_endpoint_north" {
  name                = "${var.cluster_name}-private-endpoint-north"
  location            = "UAE North"
  resource_group_name = var.node_rg
  subnet_id           = var.subnet_id_north

  private_service_connection {
    name                            = "${var.cluster_name}-privatestorageconnection"
    private_connection_resource_id  = azurerm_storage_account.aks_storage_account.id
    is_manual_connection            = false
    subresource_names               = ["file"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_a_record" "aks_st_pe_dns_a_north" {
  name                = local.storage_account_name
  zone_name           = var.private_dns_zone_name_n
  resource_group_name = var.private_dns_zone_rg_n
  ttl                 = 300
  records             = [azurerm_private_endpoint.aks_storage_private_endpoint_north.private_service_connection.0.private_ip_address]
}

resource "azurerm_private_endpoint" "aks_storage_private_endpoint_central" {
  name                = "${var.cluster_name}-private-endpoint-central"
  location            = "UAE Central"
  resource_group_name = var.node_rg
  subnet_id           = var.subnet_id_central

  private_service_connection {
    name                            = "${var.cluster_name}-privatestorageconnection"
    private_connection_resource_id  = azurerm_storage_account.aks_storage_account.id
    is_manual_connection            = false
    subresource_names               = ["file"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_a_record" "aks_st_pe_dns_a_central" {
  name                = local.storage_account_name
  zone_name           = var.private_dns_zone_name_c
  resource_group_name = var.private_dns_zone_rg_c
  ttl                 = 300
  records             = [azurerm_private_endpoint.aks_storage_private_endpoint_central.private_service_connection.0.private_ip_address]
}
