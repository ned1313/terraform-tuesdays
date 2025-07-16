variable "secret_mount_path" {
  description = "Mount path for the Vault KV v2 secret engine"
  type        = string
}

variable "secret_name" {
  description = "Name of the secret to be created in Vault"
  type        = string
}

variable "secret_version" {
  description = "Version of the secret to be created in Vault"
  type        = number

    validation {
        condition     = var.secret_version > 0 && var.secret_version == floor(var.secret_version)
        error_message = "The secret_version must be a non-negative integer."
    }
  
}

variable "vault_address" {
  description = "Address of the Vault server"
  type        = string
  default     = "http://localhost:8200"
}

variable "vault_token" {
  description = "Token for authenticating with Vault"
  type        = string
  default     = "root"
  sensitive = true

}