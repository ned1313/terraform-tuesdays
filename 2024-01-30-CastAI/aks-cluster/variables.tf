variable "prefix" {
  type        = string
  description = "Short prefix to use for naming. Should be six characters or less. Defaults to test."
  default     = "test"

  validation {
    condition     = length(var.prefix) <= 6
    error_message = "The length of the prefix must be six or less characters."
  }
}

variable "location" {
  type        = string
  description = "Region to use for deployment. Defaults to eastus."
  default     = "eastus"
}

variable "castai_api_url" {
  type        = string
  description = "URL of alternative CAST AI API to be used during development or testing"
  default     = "https://api.cast.ai"
}

# Variables required for connecting AKS cluster to CAST AI
variable "castai_api_token" {
  type        = string
  description = "CAST AI API token created in console.cast.ai API Access keys section"
}

variable "castai_grpc_url" {
  type        = string
  description = "CAST AI gRPC URL"
  default     = "grpc.cast.ai:443"
}