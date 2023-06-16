resource "azurerm_resource_group_policy_assignment" "aks_not_allow_privileged_containers" {
  name                 = "aks_not_allow_privileged_containers"
  resource_group_id    = var.cluster_rg_id
  policy_definition_id = var.aks_not_allow_privileged_containers_definition_id
  parameters           = jsonencode(
    { 
      "effect" : { 
        "value" : "${var.effect_aks_not_allow_privileged_containers}" 
      }, 
      "excludedNamespaces" : { 
        "value" : "${var.excluded_namespaces_aks_not_allow_privileged_containers}"
      } 
    }
  )
}


resource "azurerm_resource_group_policy_assignment" "aks_not_allow_container_privilege_escalation" {
  name                 = "aks_not_allow_container_privilege_escalation"
  resource_group_id    = var.cluster_rg_id
  policy_definition_id = var.aks_not_allow_container_privilege_escalation_definition_id
  parameters           = jsonencode(
    { 
      "effect" : { 
        "value" : "${var.effect_aks_not_allow_container_privilege_escalation}" 
      }, 
      "excludedNamespaces" : { 
        "value" : "${var.excluded_namespaces_aks_not_allow_container_privilege_escalation}"
      } 
    }
  )
}


resource "azurerm_resource_group_policy_assignment" "aks_not_allow_container_capabilities" {
  name                 = "aks_not_allow_container_capabilities"
  resource_group_id    = var.cluster_rg_id
  policy_definition_id = var.aks_not_allow_container_capabilities_definition_id
  parameters           = jsonencode(
    { 
      "effect" : { 
        "value" : "${var.effect_aks_not_allow_container_capabilities}" 
      }, 
      "excludedNamespaces" : { 
        "value" : "${var.excluded_namespaces_aks_not_allow_container_capabilities}"
      },
      "requiredDropCapabilities": {
        "value": ["NET_RAW"]
      },
    }
  )
    
}

