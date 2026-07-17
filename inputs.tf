variable "kubernetes_cluster_mount_path" {
  type        = string
  description = "Mount path of the Kubernetes Secrets Engine, as defined in vault-core. Ex: kubernetes/main-01-cluster-dev, kubernetes/main-01-cluster-prod."
}

variable "kubernetes_host" {
  type        = string
  description = "K8s API server URL. Ex: https://k8s-dev.internal.bouola.com."
}

variable "kubernetes_ca_cert" {
  type        = string
  sensitive   = true
  description = "PEM content of the K8s cluster CA certificate (already decoded, not base64)."
}

variable "kubernetes_service_account_jwt" {
  type        = string
  sensitive   = true
  description = "JWT token of the vault-k8s-agent ServiceAccount. Used by Vault to authenticate against the K8s API and manage ephemeral ServiceAccounts."
}

variable "vault_kubernetes_backend_roles" {
  type = list(object({
    role_name                     = string
    allowed_kubernetes_namespaces = list(string)
    token_ttl                     = optional(string, "20m")
    token_max_ttl                 = optional(string, "30m")
    rbac_rules = list(object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    }))
  }))
  default     = []
  description = "Inline list of Kubernetes CI roles."
}

variable "vault_kubernetes_backend_roles_path" {
  type        = string
  default     = null
  description = "Path to a directory of JSON files defining Kubernetes CI roles. Same pattern as vault_jwt_auth_backend_roles_path."
}
