module "aks-networking" {
  source        = "../modules/aks-networking"
  snet_name     = var.snet_name
  vnet_name     = var.vnet_name
  vnet_rg_name  = var.vnet_rg_name
  cidr          = var.cidr
  vnet_cidr     = var.vnet_cidr
  create_vnet   = var.create_vnet
  rt_name       = "${var.cluster_name}-rt"
  rg_location   = var.rg_location 
  nsg_name      = "${var.cluster_name}-nsg"
}

module "routes" {
  source          = "../modules/route"
  for_each        = { for x in var.routes: x.route_name => x }
  route_name      = each.value.route_name
  vnet_rg_name    = var.vnet_rg_name
  rt_name         = module.aks-networking.rt_name
  address_prefix  = each.value.address_prefix
  next_hop_type   = each.value.next_hop_type
  next_hop_ip     = var.routes_gateway
}

module "aks" {
  source                                                            = "../modules/aks"
  subscription_id                                                   = var.subscription_id
  subscription_id_dev                                               = var.subscription_id_dev
  # client_id_dev                                                     = var.client_id_dev
  # tenant_id_dev                                                     = var.tenant_id_dev
  # client_secret_dev                                                 = var.client_secret_dev
  rg_location                                                       = var.rg_location
  rg_name                                                           = var.rg_name
  cluster_rg_id                                                     = data.azurerm_resource_group.cluster_rg.id
  node_rg                                                           = var.node_rg
  vnet_rg_name                                                      = var.vnet_rg_name
  central_vnet_id                                                   = data.azurerm_virtual_network.central_vnet.id
  cluster_name                                                      = var.cluster_name
  default_node_pool_name                                            = var.default_node_pool_name
  default_node_pool_node_count                                      = var.default_node_pool_node_count
  default_node_pool_max_node_count                                  = var.default_node_pool_max_node_count
  default_node_pool_vm_sku                                          = var.default_node_pool_vm_sku
  default_node_pool_snet_id                                         = module.aks-networking.snet_id
  zones                                                             = var.zones
  network_plugin                                                    = var.network_plugin
  dns_service_ip                                                    = var.dns_service_ip
  docker_bridge_cidr                                                = var.docker_bridge_cidr
  service_cidr                                                      = var.service_cidr
  identity_type                                                     = var.identity_type
  aks_group_admin_id                                                = var.aks_group_admin_id
  sp_secret                                                         = data.azurerm_key_vault_secret.service_sp.value
  sp_id                                                             = data.terraform_remote_state.aks_main.outputs.aks_sp_id
  sp_pass                                                           = data.terraform_remote_state.aks_main.outputs.aks_sp_pass
  acr_id                                                            = data.azurerm_container_registry.acr.id
  environment                                                       = var.environment
  owner_tag                                                         = var.owner_tag
  admin_username                                                    = var.admin_username
  ssh_pub_key                                                       = var.ssh_pub_key
  k8s_version                                                       = var.k8s_version
  encryption_set_id                                                 = var.encryption_set_id
  aks_not_allow_privileged_containers_definition_id                 = data.azurerm_policy_definition.aks_not_allow_privileged_containers.id
  effect_aks_not_allow_privileged_containers                        = var.effect_aks_not_allow_privileged_containers                       
  excluded_namespaces_aks_not_allow_privileged_containers           = var.excluded_namespaces_aks_not_allow_privileged_containers
  aks_not_allow_container_privilege_escalation_definition_id        = data.azurerm_policy_definition.aks_not_allow_container_privilege_escalation.id
  effect_aks_not_allow_container_privilege_escalation               = var.effect_aks_not_allow_container_privilege_escalation              
  excluded_namespaces_aks_not_allow_container_privilege_escalation  = var.excluded_namespaces_aks_not_allow_container_privilege_escalation 
  aks_not_allow_container_capabilities_definition_id                = data.azurerm_policy_definition.aks_not_allow_container_capabilities.id
  effect_aks_not_allow_container_capabilities                       = var.effect_aks_not_allow_container_capabilities                      
  excluded_namespaces_aks_not_allow_container_capabilities          = var.excluded_namespaces_aks_not_allow_container_capabilities         
  cluster_list                                                      = var.RBAC_cluster_list
  # depends_on is needed to wait for route-table association to snet before cluster creation
  depends_on = [
    module.aks-networking
  ]
}

module "aks-storage" {
  source                    = "../modules/aks-storage"
  rg_location               = var.rg_location
  node_rg                   = var.node_rg
  cluster_name              = var.cluster_name
  subnet_id_north           = var.private_endpoint_snet_id_north
  subnet_id_central         = var.private_endpoint_snet_id_central
  private_dns_zone_name_n   = var.storage_private_dns_zone_name
  private_dns_zone_rg_n     = var.storage_private_dns_zone_rg_n
  private_dns_zone_name_c   = var.storage_private_dns_zone_name
  private_dns_zone_rg_c     = var.storage_private_dns_zone_rg_c
  encryption_key_id         = data.azurerm_key_vault_key.storage_encryption_key.id
  key_vault_id              = var.storage_encryption_vault_id
  cluster_principal_id      = module.aks.cluster_identity
  key_name                  = var.storage_key_name 
  tenant_id                 = var.tenant_id
  key_vault_key_id          = data.azurerm_key_vault_key.storage_encryption_key.id
}

module "aks-nodepool" {
  source          = "../modules/aks-nodepool"
  for_each        = { for x in var.nodepools: x.nodepool_name => x }
  nodepool_name   = each.value.nodepool_name
  cluster_id      = module.aks.cluster_id
  node_size       = each.value.node_size
  node_count      = each.value.node_count
  snet_id         = module.aks-networking.snet_id
  zones           = var.zones
  node_max_count  = each.value.node_max_count
  max_pods        = each.value.max_pods_used ? each.value.max_pods : null
  node_taints     = each.value.node_taint_used ? each.value.node_taint : null
  spot_instances  = each.value.spot_instances
}