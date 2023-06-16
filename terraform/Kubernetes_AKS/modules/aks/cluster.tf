resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                          = var.cluster_name
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  node_resource_group           = var.node_rg
  private_cluster_enabled       = true
  public_network_access_enabled = false
  dns_prefix                    = var.cluster_name
  kubernetes_version            = var.k8s_version
  disk_encryption_set_id        = var.encryption_set_id
  local_account_disabled        = true
  azure_policy_enabled          = true
  open_service_mesh_enabled     = false

  default_node_pool {
    name                          = var.default_node_pool_name
    node_count                    = var.default_node_pool_node_count
    vm_size                       = var.default_node_pool_vm_sku
    vnet_subnet_id                = var.default_node_pool_snet_id
    zones                         = var.zones
    only_critical_addons_enabled  = true
    enable_auto_scaling           = true
    min_count                     = var.default_node_pool_node_count
    max_count                     = var.default_node_pool_max_node_count
  }

  network_profile {
    network_plugin      = var.network_plugin
    outbound_type       = "userDefinedRouting"
    dns_service_ip      = var.dns_service_ip
    docker_bridge_cidr  = var.docker_bridge_cidr
    service_cidr        = var.service_cidr
  }

  azure_active_directory_role_based_access_control {
    managed                 = true
    azure_rbac_enabled      = true
    admin_group_object_ids  = var.aks_group_admin_id
  }

  identity {
    type          = var.identity_type
    # identity_ids  = [var.sp_id]
  }

  # service_principal {
  #   client_id     = var.sp_id
  #   client_secret = var.sp_secret
  # }

  linux_profile {
    ssh_key {
      key_data = var.ssh_pub_key
    }
    admin_username = var.admin_username
  }
  
  tags = {
    Environment = var.environment
    Owner       = var.owner_tag
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "cicd_msi_user_assignement" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "Azure Kubernetes Service Cluster User Role"
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "cicd_msi_cluster_admin_assignement" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                            = azurerm_kubernetes_cluster.aks_cluster.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "devops_cicd_msi_user_assignement" {
  count                            = length(var.cluster_list)
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "Azure Kubernetes Service Cluster User Role"
  scope                            = var.cluster_list[count.index]
  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "devops_cicd_msi_cluster_admin_assignement" {
  count                            = length(var.cluster_list)
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                            = var.cluster_list[count.index]
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_acr_link" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = "/subscriptions/${var.subscription_id}/resourceGroups/${var.vnet_rg_name}"
  skip_service_principal_aad_check = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_to_central" {
  name = "link_to_cenral"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.aks_cluster.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.aks_cluster.private_fqdn))))
  resource_group_name   = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  virtual_network_id    = var.central_vnet_id
  lifecycle {
    ignore_changes = [tags]
  }
}


# resource "azurerm_role_assignment" "admin_group_RBAC" {
#   for_each              = toset(var.aks_group_admin_id)
#   principal_id          = each.value
#   role_definition_name  = "Azure Kubernetes Service RBAC Admin"
#   scope                 = azurerm_kubernetes_cluster.aks_cluster.id
# }

resource "azurerm_role_assignment" "admin_group_cluster_user" {
  for_each              = toset(var.aks_group_admin_id)
  principal_id          = each.value
  role_definition_name  = "Azure Kubernetes Service Cluster User Role"
  scope                 = azurerm_kubernetes_cluster.aks_cluster.id
}