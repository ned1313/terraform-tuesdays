variable "key_vault_secret_name" {
  description = "The name of the secret in the Azure Key Vault."
  type        = string
}

variable "key_vault_certificate_name" {
  description = "The name of the certificate in the Azure Key Vault."
  type        = string

}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault."
  type        = string

}