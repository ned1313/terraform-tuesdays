# The GitHub repo where we'll be creating secrets
variable "repository_name" {
  type        = string
  description = "(Required) The name of the repository we're using in the form (org | user)/repo"
}

variable "azure_region" {
  type        = string
  description = "(Optional) Azure region to use for storage account. Defaults to East US."
  default     = "eastus"
}

variable "environments" {
  type        = list(string)
  description = "(Requireds) The branches to use for the references."
}