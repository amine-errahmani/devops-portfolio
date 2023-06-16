variable "subscription_id" {} # defined as ENV Variable
variable "subscription_id_dev" {} # defined as ENV Variable
# variable "client_id_dev" {}
# variable "tenant_id_dev" {}
# variable "client_secret_dev" {}
variable "tenant_id" {} # defined as ENV Variable

variable "main_backend_key" {}

variable "environment" {}

variable "snet_name" {}
variable "vnet_name" {}
variable "vnet_rg_name" {}
variable "vnet_name_c" {}
variable "vnet_rg_name_c" {}
variable "cidr" {
  type = list(string)
}
variable "vnet_cidr" {
  type = list(string)
}
variable "create_vnet" {
    type = bool
}

variable "rg_location" {}
variable "rg_name" {}
variable "node_rg" {}
variable "cluster_name" {}

variable "default_node_pool_name" {}
variable "default_node_pool_node_count" {}
variable "default_node_pool_vm_sku" {}
variable "default_node_pool_max_node_count" {}
variable "zones" {}

variable "network_plugin" {}
variable "dns_service_ip" {}
variable "docker_bridge_cidr" {}
variable "service_cidr" {}

variable "identity_type" {}
variable "aks_group_admin_id" {}

variable "acr_name" {}
variable "acr_rg" {}

variable "owner_tag" {}
variable "admin_username" {}

variable "vault_state_path" {}
variable "storage_account" {}
variable "container" {}
variable "avi_sp" {}

variable "ssh_pub_key" {}

variable "k8s_version" {}

variable "encryption_set_id" {}

variable "nodepools" {
  type = list(any)
}

variable "routes_gateway" {}

variable "routes" {
  type = list(any)
}

variable "effect_aks_not_allow_privileged_containers" {}
variable "excluded_namespaces_aks_not_allow_privileged_containers" {}
variable "effect_aks_not_allow_container_privilege_escalation" {}
variable "excluded_namespaces_aks_not_allow_container_privilege_escalation" {}
variable "effect_aks_not_allow_container_capabilities" {}
variable "excluded_namespaces_aks_not_allow_container_capabilities" {}

variable "private_endpoint_snet_id_north" {}
variable "private_endpoint_snet_id_central" {}

variable "storage_private_dns_zone_name" {}
variable "storage_private_dns_zone_rg_n" {}
variable "storage_private_dns_zone_rg_c" {}

variable "storage_encryption_vault_id" {}
variable "storage_key_name" {}
# variable "storage_key_version" {}

variable "RBAC_cluster_list" {
  type = list(string)
}