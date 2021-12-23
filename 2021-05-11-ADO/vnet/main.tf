###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"

    }
  }

  backend "azurerm" {
    
  }
}

###########################
# VARIABLES
###########################

variable "region" {
  type        = string
  description = "Region in Azure"
  default     = "canadacentral"
}

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "test131313"
}

###########################
# PROVIDERS
###########################

provider "azurerm" {
  ARM_SAS_TOKEN = var.sas_token
  ARM_CLIENT_ID = var.az_client_id
  ARM_CLIENT_SECRET = var.az_client_secret
  ARM_SUBSCRIPTION_ID = var.az_subscription
  ARM_TENANT_ID = var.az_tenant
  features {}
}

###########################
# DATA SOURCES
###########################

locals {
  name = "${var.prefix}-${random_id.seed.hex}"
}

###########################
# RESOURCES
###########################

resource "random_id" "seed" {
  byte_length = 4
}

resource "azurerm_resource_group" "vnet" {
  name     = local.name
  location = var.region
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.vnet.name
  vnet_name           = local.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.0.0/24","10.0.2.0/24","10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2","subnet3"]

  depends_on = [azurerm_resource_group.vnet]
}

variable {
    name         = "sas_token"
    secret_value = var.sas_token
    is_secret    = true
  }

  variable {
    name         = "az_client_id"
    secret_value = var.az_client_id
    is_secret    = true
  }

  variable {
    name         = "az_client_secret"
    secret_value = var.az_client_secret
    is_secret    = true
  }

  variable {
    name         = "az_subscription"
    secret_value = var.az_subscription
    is_secret    = true
  }

  variable {
    name         = "az_tenant"
    secret_value = var.az_tenant
    is_secret    = true
  }