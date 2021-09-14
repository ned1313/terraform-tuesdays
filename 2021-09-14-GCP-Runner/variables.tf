variable "billing_account" {
  type        = string
  description = "Billing account to associate with the project being created."
}

variable "org_id" {
  type        = string
  description = "Organization ID to associate with the project being created"
}
variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Default zone to use for MIG runner deployment"
  default     = "us-central1-a"
}

variable "gcp_bucket_location" {
  type        = string
  description = "Location of Google Cloud bucket"
  default     = "US"
}

variable "gh_org_name" {
  type        = string
  description = "Name of the GitHub organization to request a runner token from"
}

variable "gh_org_url" {
  type        = string
  description = "URL for the GitHub organization to register a runner with."
}

variable "gh_token" {
  type        = string
  description = "GitHub token with permissions to request a runner token."
}

variable "prefix" {
  type        = string
  description = "Prefix for naming the project and other resources"
  default     = "taco"
}

locals {
  gcp_service_account_name = "${var.prefix}-gh-runner-account"
}