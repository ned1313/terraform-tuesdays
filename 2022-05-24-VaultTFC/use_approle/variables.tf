variable "tenant_id" {
  type        = string
  description = "The Azure Active Directory tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID"
}

variable "approle_path" {
  type        = string
  description = "The AppRole path without the trailing slash"
}

variable "role_id" {
  type        = string
  description = "The AppRole role ID"
}

variable "secret_id" {
  type        = string
  description = "The AppRole secret ID"
  sensitive   = true
}

variable "vault_azure_secret_backend_path" {
  type        = string
  description = "The Azure Secrets path in vault without the trailing slash"
}

variable "vault_azure_secret_backend_role_name" {
  type        = string
  description = "The Azure Secrets role name in Vault"
}

variable "vault_namespace" {
  type = string
  description = "The Vault namespace"
  default = null
}
  