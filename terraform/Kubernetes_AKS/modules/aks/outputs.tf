output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}
output "cluster_identity" {
  value = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}

output "private_dns_zone_name" {
  value = join(".", slice(split(".", azurerm_kubernetes_cluster.aks_cluster.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.aks_cluster.private_fqdn))))
}
