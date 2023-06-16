output "aks_sp_id" {
 value = module.sp.sp_id
}

output "aks_sp_pass" {
 value = module.sp.sp_password
 sensitive   = true
}
