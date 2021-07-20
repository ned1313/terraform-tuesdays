# Google Cloud variables
variable "billing_account" {
  type        = string
  description = "Billing account to associate with the project being created."
}

variable "org_id" {
  type        = string
  description = "Organization ID to associate with the project being created"
}
variable "region" {
  type        = string
  description = "Default region to use for the project"
  default     = "us-central1"
}

variable "prefix" {
  type = string
  description = "Prefix for naming the project and other resources"
  default = "taconet"
}

provider "google" {
  region = var.region
}

# Random id for naming
resource "random_id" "id" {
  byte_length = 4
  prefix      = var.prefix
}

# Create a Google project for Compute Engine
resource "google_project" "project" {
  name            = random_id.id.hex
  project_id      = random_id.id.hex
  billing_account = var.billing_account
  org_id          = var.org_id
}

# Enable the necessary services on the project for deployments
resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com"

  ])

  service = each.key

  project            = google_project.project.project_id
  disable_on_destroy = false
}

# Provide the project information for another user
output "project_id" {
  value = google_project.project.project_id
}