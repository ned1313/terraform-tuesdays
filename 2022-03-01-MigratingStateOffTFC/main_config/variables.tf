#############################################################################
# VARIABLES
#############################################################################

variable "location" {
  description = "(Optional) Region where the Azure resources will be created. Defaults to East US."
  type        = string
  default     = "eastus"
}

variable "naming_prefix" {
  description = "(Optional) Naming prefix used for resources. Defaults to adolabs."
  type        = string
  default     = "tfc"
}

variable "asp_tier" {
  description = "(Required) Tier for App Service Plan (Standard, PremiumV2)."
  type        = string
  default     = "Standard"
}

variable "asp_size" {
  description = "(Required) Size for App Service Plan (S2, P1v2)."
  type        = string
  default     = "S1"
}

variable "capacity" {
  description = "(Optional) Number of instances for App Service Plan."
  type        = string
  default     = "1"
}