variable "prefix" {
  description = "The prefix for the database naming."
  type        = string
}

variable "db_password_info" {
  type = object({
    key_vault_id          = string
    key_vault_secret_name = string
    version               = string
  })
}