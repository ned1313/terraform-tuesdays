variable "location" {
  type        = string
  description = "(Optional) The Azure region where the resources should be created."
  default     = "westus"
}

variable "prefix" {
  type        = string
  description = "(Optional) The prefix for the name of the resources."
  default     = "avd"
}