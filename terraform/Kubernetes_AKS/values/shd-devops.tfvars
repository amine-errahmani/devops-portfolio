#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  General 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
environment = "env"

rg_location         = "UAE North"
rg_name             = "env-devops-rg"
node_rg             = "env-devops-svc-rg"
cluster_name        = "env-devops"
k8s_version         = "1.23.8"

identity_type       = "SystemAssigned"
aks_group_admin_id  = [""]

acr_name    = "acr"
acr_rg      = "acr-rg"

owner_tag       = "Devops Team"
admin_username  = "devops"

vault_state_path    = ""
storage_account     = ""
container           = ""

main_backend_key = "env/aks/devops/main/terraform.tfstate"

ssh_pub_key = ""

encryption_set_id = ""

storage_encryption_vault_id = ""
storage_key_name            = ""

RBAC_cluster_list = [""]

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Compute 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
default_node_pool_name              = "system"
default_node_pool_node_count        = 3
default_node_pool_vm_sku            = "Standard_DS2_v2"
default_node_pool_max_node_count    = 4
zones = [1,2,3]

nodepools = [
    {
        nodepool_name   = "app",
        node_size       = "Standard_DS13_v2",
        node_count      = 3
        node_max_count  = 7
        max_pods_used   = true
        max_pods        = 70
        spot_instances  = false
        node_taint_used = false
        node_taint      = []
    },
    {
        nodepool_name   = "kafka",
        node_size       = "Standard_DS13_v2", 
        node_count      = 6
        node_max_count  = 10
        max_pods_used   = true
        max_pods        = 70
        spot_instances  = false
        node_taint_used = true
        node_taint      = ["usage-type=kafka-cluster:NoSchedule"]
    },
    {
        nodepool_name   = "airflow",
        node_size       = "Standard_DS5_v2",
        node_count      = 1
        node_max_count  = 15
        max_pods_used   = true
        max_pods        = 70
        spot_instances  = true
        node_taint_used = true
        node_taint      = ["usage-type=airflow-runners:NoSchedule", "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
    }
]

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Networking 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
snet_name           = "env-AKS-DEVOPS-subnet"
vnet_name           = "env-VNET"
vnet_rg_name        = "env-network-rg"
vnet_name_c         = "env-VNET-dr"
vnet_rg_name_c      = "env-network-rg-dr"
cidr                = ["10.0.0.0/16"]
vnet_cidr           = [""]
create_vnet         = false

network_plugin      = "azure"
dns_service_ip      = "172.100.0.10"
docker_bridge_cidr  = "172.101.0.1/16"
service_cidr        = "172.100.0.0/24"

private_endpoint_snet_id_north    = ""
private_endpoint_snet_id_central  = ""

storage_private_dns_zone_name   = "privatelink.file.core.windows.net"
storage_private_dns_zone_rg_n   = "env-network-rg"
storage_private_dns_zone_rg_c   = "env-network-rg-dr"

routes_gateway = "10.0.0.254"

routes = [
    {
        route_name = "Default-Route",
        address_prefix = "0.0.0.0/0",
        next_hop_type = "VirtualAppliance"
    },
    {
        route_name = "Route1",
        address_prefix = "10.0.0.0/16",
        next_hop_type = "VirtualAppliance"
    },
    {
        route_name = "Route2",
        address_prefix = "10.1.0.0/16",
        next_hop_type = "VnetLocal"
    }
]


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Policies 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
effect_aks_not_allow_privileged_containers              = "deny"
excluded_namespaces_aks_not_allow_privileged_containers = ["kube-system", "gatekeeper-system", "calico-system", "tigera-system", "cert-manager", "self-hosted-runners", "jenkins"]

effect_aks_not_allow_container_privilege_escalation                 = "deny"
excluded_namespaces_aks_not_allow_container_privilege_escalation    = ["kube-system", "gatekeeper-system", "calico-system", "tigera-system", "cert-manager", "monitoring-stack", "self-hosted-runners", "jenkins"]

effect_aks_not_allow_container_capabilities                 = "deny"
excluded_namespaces_aks_not_allow_container_capabilities    = ["kube-system", "gatekeeper-system", "calico-system", "tigera-system", "cert-manager", "splunk", "jenkins", "monitoring-stack", "self-hosted-runners"]
