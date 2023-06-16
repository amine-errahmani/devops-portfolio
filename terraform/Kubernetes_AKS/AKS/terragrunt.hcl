remote_state {
  backend = "azurerm" 
  config = {
    storage_account_name = "${get_env("storage_account", "deploy")}"
    container_name       = "terraformbackend"
    key                  = "${get_env("TF_VAR_ENV", "empty")}/aks/${get_env("TF_VAR_CLUSTER", "empty")}/k8s/terraform.tfstate"
  }
}