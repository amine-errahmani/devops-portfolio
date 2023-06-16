variable "subscription_id" {}
variable "subscription_id_dev" {}
# variable "client_id_dev" {}
# variable "tenant_id_dev" {}
# variable "client_secret_dev" {}

variable "rg_location" {}
variable "rg_name" {}
variable "node_rg" {}
variable "vnet_rg_name" {}
variable "central_vnet_id" {}

variable "cluster_rg_id" {}

variable "cluster_name" {}

variable "default_node_pool_name" {}
variable "default_node_pool_node_count" {}
variable "default_node_pool_vm_sku" {}
variable "default_node_pool_snet_id" {}
variable "default_node_pool_max_node_count" {}
variable "zones" {}

variable "network_plugin" {}
variable "dns_service_ip" {}
variable "docker_bridge_cidr" {}
variable "service_cidr" {}

variable "identity_type" {}

variable "aks_group_admin_id" {}

variable "sp_secret" {}
variable "sp_id" {}
variable "sp_pass" {} 

variable "acr_id" {}

variable "environment" {}
variable "owner_tag" {}

variable "admin_username" {}
variable "ssh_pub_key" {}

variable "k8s_version" {}

variable "encryption_set_id" {}

variable "aks_not_allow_privileged_containers_definition_id" {}
variable "effect_aks_not_allow_privileged_containers" {}
variable "excluded_namespaces_aks_not_allow_privileged_containers" {}
variable "aks_not_allow_container_privilege_escalation_definition_id" {}
variable "effect_aks_not_allow_container_privilege_escalation" {}
variable "excluded_namespaces_aks_not_allow_container_privilege_escalation" {}
variable "aks_not_allow_container_capabilities_definition_id" {}
variable "effect_aks_not_allow_container_capabilities" {}
variable "excluded_namespaces_aks_not_allow_container_capabilities" {}

variable "cluster_list" {
  type = list(string)
}