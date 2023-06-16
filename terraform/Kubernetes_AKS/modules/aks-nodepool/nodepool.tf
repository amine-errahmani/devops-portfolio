resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  name                  = var.nodepool_name
  kubernetes_cluster_id = var.cluster_id
  vm_size               = var.node_size
  node_count            = var.node_count
  vnet_subnet_id        = var.snet_id
  zones                 = var.spot_instances ? null : var.zones
  enable_auto_scaling   = true
  min_count             = var.node_count
  max_count             = var.node_max_count
  max_pods              = var.max_pods
  node_taints           = var.node_taints
  priority              = var.spot_instances ? "Spot" : "Regular"
  eviction_policy       = var.spot_instances ? "Deallocate" : null
  spot_max_price        = var.spot_instances ? "-1" : null

  lifecycle {
    ignore_changes = [node_count]
  }
}