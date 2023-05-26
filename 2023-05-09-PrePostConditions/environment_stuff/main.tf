variable "environment_tag" {
  type        = string
  description = "Tag to use for Environment"
  default     = "Staging"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to use."
}

variable "configuration_store_id" {
  type        = string
  description = "ID of the configuration store to use."
}

variable "region" {
  type        = string
  description = "Region to use."
  default     = "eastus"
}

provider "azurerm" {
  features {

  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name

  lifecycle {
    postcondition {
      condition     = length(self.tags) > 0 && contains(keys(self.tags), "Environment")
      error_message = "The resource group ${var.resource_group_name} does not have an Environment tag."
    }

    postcondition {
      condition     = self.tags["Environment"] == var.environment_tag
      error_message = "The resource group ${var.resource_group_name} does not have the correct Environment tag."
    }
  }
}

data "azurerm_app_configuration_key" "cidr_list" {
  configuration_store_id = var.configuration_store_id
  key                    = "cidr_lists"
  label                  = var.region
}