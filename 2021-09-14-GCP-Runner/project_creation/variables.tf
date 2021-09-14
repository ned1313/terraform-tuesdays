
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

variable "prefix" {
  type        = string
  description = "Prefix for naming the project and other resources"
  default     = "taco"
}