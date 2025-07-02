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
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "db_password_version" {
  description = "The version of the database password to be stored in the Key Vault."
  type        = number

  validation {
    condition     = var.db_password_version > 0 && var.db_password_version == floor(var.db_password_version)
    error_message = "The db_password_version must be a non-negative integer."
  }
}