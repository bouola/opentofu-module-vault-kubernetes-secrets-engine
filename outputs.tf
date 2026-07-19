output "role_names" {
  value       = { for k, v in vault_kubernetes_secret_backend_role.kubernetes_backend_roles : k => v.name }
  description = "Map of created K8s CI roles. Key = role_name, value = Vault name."
}

output "policy_names" {
  value       = { for k, v in vault_policy.kubernetes_policies : k => v.name }
  description = "Map of created Vault policies. Reference these in your GitLab JWT role token_policies."
}

output "creds_paths" {
  value = {
    for k, v in vault_kubernetes_secret_backend_role.kubernetes_backend_roles :
    k => "${local.mount_path}/creds/${v.name}"
  }
  description = "Map of Vault paths to generate ephemeral SA tokens. Use in CI: vault write <path> kubernetes_namespace=<ns>."
}
