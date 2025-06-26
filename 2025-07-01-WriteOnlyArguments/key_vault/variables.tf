variable "prefix" {
  description = "The prefix for the Key Vault name."
  type        = string
}

variable "db_password_regular" {
  description = "The database password to be stored in the Key Vault."
  type        = string
  sensitive   = true
}

variable "db_password_ephemeral" {
  description = "The ephemeral database password to be stored in the Key Vault."
  type        = object({
    value   = string
    version = string
  })
  sensitive   = true
}