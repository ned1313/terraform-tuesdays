# We're going to create a basic MS Web App listening on port 80
# The application should load a simple app that responds on port 443

terraform {
  required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = "~> 2.0"
      }
  }

  backend "remote" {
    organization = "ned-in-the-cloud"

    workspaces {
      name = "terraform-tuesday-module-testing"
    }
  }
}

provider "azurerm" {
  features {}
  
}

variable "prefix" {
  type = string
  description = "Naming prefix for web app"
  default = "tacos"
}

variable "location" {
  type = string
  description = "Region to use for web app"
  default = "eastus"
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  name = "${var.prefix}-${random_id.id.hex}"
}

resource "azurerm_resource_group" "webapp" {
  name = local.name
  location = var.location
}

resource "azurerm_container_group" "webapp" {
  name                = local.name
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name
  ip_address_type     = "public"
  dns_name_label      = local.name
  os_type             = "Linux"

  container {
    name   = "petstore"
    image  = "swaggerapi/petstore"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      SWAGGER_HOST = "http://${local.name}.${azurerm_resource_group.webapp.location}.azurecontainer.io"
      SWAGGER_URL = "http://${local.name}.${azurerm_resource_group.webapp.location}.azurecontainer.io:8080"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}

data "http" "url_test" {
    url = "http://${azurerm_container_group.webapp.fqdn}:8080"
}

output "url" {
  value = azurerm_container_group.webapp.fqdn
}

output "response" {
  value = data.http.url_test.body
}

output "headers" {
  value = data.http.url_test.response_headers
}