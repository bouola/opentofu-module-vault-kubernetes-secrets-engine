locals {
  mount_path = var.kubernetes_cluster_mount_path

  roles_from_list = { for role in var.vault_kubernetes_backend_roles : role.role_name => role }
  role_json_files = var.vault_kubernetes_backend_roles_path != null ? fileset(var.vault_kubernetes_backend_roles_path, "*.json") : []
  decoded_json_roles = [
    for file in local.role_json_files :
    jsondecode(file("${var.vault_kubernetes_backend_roles_path}/${file}"))
  ]
  roles_from_json = { for role in local.decoded_json_roles : role.role_name => role }
  all_roles       = merge(local.roles_from_list, local.roles_from_json)
}

resource "vault_kubernetes_secret_backend" "kubernetes_backend_config" {
  path                = var.kubernetes_cluster_mount_path
  kubernetes_host     = var.kubernetes_host
  kubernetes_ca_cert  = var.kubernetes_ca_cert
  service_account_jwt = var.kubernetes_service_account_jwt
}

# ------------------------------------------------------------------------------
# Kubernetes CI roles
# Each role defines: allowed namespaces, RBAC rules, generated token TTL.
# ------------------------------------------------------------------------------
resource "vault_kubernetes_secret_backend_role" "kubernetes_backend_roles" {
  for_each = local.all_roles

  backend = var.kubernetes_cluster_mount_path
  name    = endswith(each.value.role_name, "-role") ? each.value.role_name : "${each.value.role_name}-role"

  allowed_kubernetes_namespaces = each.value.allowed_kubernetes_namespaces

  token_ttl     = lookup(each.value, "token_ttl", "20m")
  token_max_ttl = lookup(each.value, "token_max_ttl", "30m")

  # Vault expects a valid YAML string for generated_role_rules
  generated_role_rules = yamlencode({
    rules = [
      for rule in each.value.rbac_rules : {
        apiGroups = rule.api_groups
        resources = rule.resources
        verbs     = rule.verbs
      }
    ]
  })

  # Namespace-scoped Role, not ClusterRole
  kubernetes_role_type = "Role"
}

# ------------------------------------------------------------------------------
# Vault policies — one per role
# Allows calling the token generation path for that specific role.
# ------------------------------------------------------------------------------
resource "vault_policy" "kubernetes_policies" {
  for_each = local.all_roles
  name     = "k8s-${vault_kubernetes_secret_backend_role.kubernetes_backend_roles[each.key].name}-${replace(var.kubernetes_cluster_mount_path, "/", "-")}-policy"

  policy = <<-EOT
    # Generate ephemeral SA tokens — ${vault_kubernetes_secret_backend_role.kubernetes_backend_roles[each.key].name} on ${var.kubernetes_cluster_mount_path}
    path "${var.kubernetes_cluster_mount_path}/creds/${vault_kubernetes_secret_backend_role.kubernetes_backend_roles[each.key].name}" {
      capabilities = ["create", "update"]
    }

    # Read cluster CA cert
    path "${var.vault_kubernetes_ca_cert_kv_full_path}" {
      capabilities = ["read"]
    }
  EOT
}
