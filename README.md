<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 5.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 5.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_kubernetes_secret_backend.kubernetes_backend_config](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_secret_backend) | resource |
| [vault_kubernetes_secret_backend_role.kubernetes_backend_roles](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_secret_backend_role) | resource |
| [vault_policy.kubernetes_policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_ca_cert"></a> [kubernetes\_ca\_cert](#input\_kubernetes\_ca\_cert) | PEM content of the K8s cluster CA certificate (already decoded, not base64). | `string` | n/a | yes |
| <a name="input_kubernetes_cluster_mount_path"></a> [kubernetes\_cluster\_mount\_path](#input\_kubernetes\_cluster\_mount\_path) | Mount path of the Kubernetes Secrets Engine, as defined in vault-core. Ex: kubernetes/main-01-cluster-dev, kubernetes/main-01-cluster-prod. | `string` | n/a | yes |
| <a name="input_kubernetes_host"></a> [kubernetes\_host](#input\_kubernetes\_host) | K8s API server URL. Ex: https://k8s-dev.internal.bouola.com. | `string` | n/a | yes |
| <a name="input_kubernetes_service_account_jwt"></a> [kubernetes\_service\_account\_jwt](#input\_kubernetes\_service\_account\_jwt) | JWT token of the vault-k8s-agent ServiceAccount. Used by Vault to authenticate against the K8s API and manage ephemeral ServiceAccounts. | `string` | n/a | yes |
| <a name="input_vault_kubernetes_backend_roles"></a> [vault\_kubernetes\_backend\_roles](#input\_vault\_kubernetes\_backend\_roles) | Inline list of Kubernetes CI roles. | <pre>list(object({<br/>    role_name                     = string<br/>    allowed_kubernetes_namespaces = list(string)<br/>    token_ttl                     = optional(string, "20m")<br/>    token_max_ttl                 = optional(string, "30m")<br/>    rbac_rules = list(object({<br/>      api_groups = list(string)<br/>      resources  = list(string)<br/>      verbs      = list(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_vault_kubernetes_backend_roles_path"></a> [vault\_kubernetes\_backend\_roles\_path](#input\_vault\_kubernetes\_backend\_roles\_path) | Path to a directory of JSON files defining Kubernetes CI roles. Same pattern as vault\_jwt\_auth\_backend\_roles\_path. | `string` | `null` | no |
| <a name="input_vault_kubernetes_ca_cert_kv_full_path"></a> [vault\_kubernetes\_ca\_cert\_kv\_full\_path](#input\_vault\_kubernetes\_ca\_cert\_kv\_full\_path) | Vault KV full path(with mounts for policy) where the decoded CA cert is stored. Ex: secrets/data/infra/kubernetes/main-01-cluster-prod/ca-cert. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_creds_paths"></a> [creds\_paths](#output\_creds\_paths) | Map of Vault paths to generate ephemeral SA tokens. Use in CI: vault write <path> kubernetes\_namespace=<ns>. |
| <a name="output_policy_names"></a> [policy\_names](#output\_policy\_names) | Map of created Vault policies. Reference these in your GitLab JWT role token\_policies. |
| <a name="output_role_names"></a> [role\_names](#output\_role\_names) | Map of created K8s CI roles. Key = role\_name, value = Vault name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
