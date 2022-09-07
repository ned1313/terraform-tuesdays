terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
    features {}
    alias = "sub1"
    subscription_id = var.sub1
}

provider "azurerm" {
    features {}
    alias = "sub2"
    subscription_id = var.sub2
}

resource "azurerm_resource_group" "sub1_net" {
  name = "sub1_net"
  location = "eastus"
}

ami = var.aws_amis[var.aws_region]

resource "azurerm_resource_group" "sub2_net" {
    count = var.sub2_create ? 1 : 0
  name = "sub2_net"
  location = "eastus"
}