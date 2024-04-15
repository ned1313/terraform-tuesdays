variable "location" {
  type        = string
  description = "Location for Azure Resource Group."
}

variable "azp_org_name" {
  description = "Name of your Azure DevOps Organization."
  type        = string
}

variable "azp_token" {
  description = "Personal access token for your Azure DevOps Organziation."
  type        = string
}

variable "azp_pool" {
  description = "Name of the agent pool you created in Azure DevOps. If not set, a new pool named aci-agents will be created."
  type        = string
  default     = ""
}

variable "agent_image" {
  description = "Docker image for the self-hosted agent."
  type        = string
  default     = "ned1313/azp-agent:1.2.0"
}