# The GitHub repo where we'll be creating secrets and environments
variable "repository_name" {
  type        = string
  description = "(Required) The name of the repository we're using in the form (org | user)/repo"
}

variable "env_sub_ids" {
  type = map(string)
  description = "(Required) A map of GitHub environments to Azure subscription IDs."
}

variable "azure_region" {
  type = string
  description = "(Optional) Azure region to use for storage account. Defaults to East US."
  default = "eastus"
}
