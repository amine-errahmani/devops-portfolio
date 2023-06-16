remote_state {
  backend = "azurerm" 
  config = {
    storage_account_name = "${get_env("storage_account", "storage")}"
    container_name       = "terraformbackend"
    key                  = "${get_env("TF_VAR_ENV", "empty")}/${get_env("TF_VAR_COMPONENT", "vendor")}/${get_env("TF_VAR_MODULE", "MAIN_app2")}/${get_env("TF_VAR_VERSION", "vx.x.x")}/terraform.tfstate"
  }
}