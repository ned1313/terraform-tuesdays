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