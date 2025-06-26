variable "location" {
  description = "The location/region where the Azure Key Vault should be created."
  default     = "East US"

}

variable "prefix" {
  description = "A prefix to apply to all resources in this example."
  default     = "tacos"
}