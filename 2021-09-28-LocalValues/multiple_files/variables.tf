variable "region" {
  type        = string
  description = "Region in Azure"
  default     = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "taco"
}