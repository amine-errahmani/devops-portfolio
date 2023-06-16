# resource "azurerm_virtual_machine_extension" "app4_oms" {
#   count                 = length(var.resource_group_locations)
#   name                  = "OMSExtension"
#   location              = element(var.resource_group_locations, count.index)
#   resource_group_name   = element(var.resource_group_names, count.index)
#   virtual_machine_name  = element(azurerm_virtual_machine.app4_vm.*.name, count.index)
#   publisher             = "Microsoft.EnterpriseCloud.Monitoring"
#   type                  = "MicrosoftMonitoringAgent"
#   type_handler_version  = "1.0"

#   settings = <<-BASE_SETTINGS
#   {
#     "workspaceId" : element(data.terraform_remote_state.logaw.outputs.workspace_id, 0)
#   }
#   BASE_SETTINGS

#   protected_settings = <<-PROTECTED_SETTINGS
#   {
#     "workspaceKey" : element(data.terraform_remote_state.logaw.outputs.primary_key, 0)
#   }
#   PROTECTED_SETTINGS
# }

# resource "azurerm_virtual_machine_extension" "domain_join_example" { # can be used for scalesets as well
#   name                 = "domain_join_example"
#   location             = "${var.resource_group_location}"
#   resource_group_name  = "${var.resource_group_name}"
#   virtual_machine_name = "${var.prefix}"
#   publisher            = "Microsoft.Compute"
#   type                 = "JsonADDomainExtension"
#   type_handler_version = "1.3"

#   # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
#   settings = <<SETTINGS
#     {
#         "Name": "infra.com",
#         "OUPath": "OU=WQFE,OU=SIT,OU=Servers,DC=infra,DC=com",
#         "User": "infra.com\\itops",
#         "Restart": "true",
#         "Options": "3"
#     }
#     SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#         "Password": "${var.admin_password}"
#     }
#     PROTECTED_SETTINGS
# }

# resource "azurerm_virtual_machine_extension" "app4_postconf" {
#   count                 = length(var.resource_group_locations)
#   name                  = "app4_postconf-${element(var.region_suffix, count.index)}"
#   virtual_machine_id    = element(azurerm_virtual_machine.app4_vm.*.id, count.index)
#   publisher             = "Microsoft.Compute"
#   type                  = "CustomScriptExtension"
#   type_handler_version  = "1.10"
#   
#   settings = <<SETTINGS
#   {
#     "commandToExecute": "powershell -command \"E:\\scripts\\app4_task_import.ps1 ${var.admin_username} ${var.admin_password} | Out-File -filepath E:\\vendor\\logs\\app4_task_import_output.log; E:\\scripts\\app4_fileshare.ps1 ${var.app4_fileshare} ${var.app4_fileshare_pass} ${var.environment} | Out-File -filepath E:\\vendor\\logs\\app4_fileshare_output.log\""
#   }
#   SETTINGS
# }





