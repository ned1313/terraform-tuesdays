variable "az_identity_name" {
  type        = string
  description = "(Required) Name of application and service principal."
}

variable "az_owner_id" {
  type        = string
  description = "(Optional) Object ID of owner to be assigned to service principal. Assigned to current user if not set."
  default     = null
}

variable "az_subscription_id" {
  type        = string
  description = "(Optional) Subscription ID service principal with received Contributor permissions on. Assigned to current subscription if not set."
  default     = null
}

variable "az_alias" {
  type        = string
  description = "(Optional) Alias for aliased identity. Defaults to security."
  default     = "security"
}

variable "tfc_hostname" {
  type        = string
  description = "(Optional) Hostname of Terraform Cloud instance. Defaults to app.terraform.io."
  default     = "app.terraform.io"
}

variable "tfc_organization_name" {
  type        = string
  description = "(Required) Name of the Terraform Cloud organization."
}

variable "tfc_project_name" {
  type        = string
  description = "(Required) Name of the Terraform Cloud project."
}

variable "tfc_workspace_name" {
  type        = string
  description = "(Required) Name of the Terraform Cloud workspace."
}