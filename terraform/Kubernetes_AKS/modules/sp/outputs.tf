output "sp_id" {
 value = azuread_service_principal.sp.application_id
}

output "sp_password" {
 value = azuread_service_principal_password.sp_pass
 sensitive   = true
}
