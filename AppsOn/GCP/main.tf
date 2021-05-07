###########################
# CONFIGURATION
###########################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"

    }
  }
}

###########################
# VARIABLES
###########################

variable "project_id" {
  type = string
  description = "Project ID to create VPC in"
}

variable "region" {
  type        = string
  description = "Region in GCP"
  default     = "us-central1"
}

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "flan"
}

###########################
# PROVIDERS
###########################

provider "google" {
  project = var.project_id
  region = var.region
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

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"

    project_id   = var.project_id
    network_name = local.name
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "${local.name}-01"
            subnet_ip             = "10.0.0.0/24"
            subnet_region         = var.region
        },
        {
            subnet_name           = "${local.name}-02"
            subnet_ip             = "10.0.1.0/24"
            subnet_region         = var.region
        }
    ]

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]
}