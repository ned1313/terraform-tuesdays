#########################################################################################
# This configuration creates a project and App Engine instance in GCP
# and it creates a MongoDB cluster through Atlas on GCP
# Follow the directions here to set up a Terraform service account in GCP
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#
# Follow the directions here to set up a keypair for Atlas to enable programmatic access
# https://www.mongodb.com/atlas/hashicorp-terraform
#
# Happy Terraforming!
#########################################################################################

###########################
# VARIABLES
############################

# Google Cloud variables
variable "billing_account" {
  type = string
  description = "Billing account to associate with the project being created."
}

variable "org_id" {
  type = string
  description = "Organization ID to associate with the project being created"
}
variable "region" {
  type = string
  description = "Default region to use for the project"
    default = "us-central1"
}

# App engine location
variable "location_id" {}

# MongoDB Atlas provider info
variable "mongodbatlas_region_name" {
    default = "CENTRAL_US"
}
variable "mongodbatlas_public_key" {}

# Set this using the environment variable TF_VAR_mongodbatlas_private_key
variable "mongodbatlas_private_key" {}

variable "mongodbatlas_org_id" {}

# Set this using the environment variable TF_VAR_mongodbatlas_database_password
variable "mongodbatlas_database_password" {}


############################
# PROVIDERS
############################

provider "google" {
  version = "~>2.0"
  region      = var.region
}

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

#############################################################################
# DATA SOURCES
#############################################################################

data "http" "my_ip" {
    url = "http://ifconfig.me"
}

############################
# RESOURCES
############################

# Create a project for the new cluster
resource "mongodbatlas_project" "run" {
  name   = terraform.workspace
  org_id = var.mongodbatlas_org_id
}

# Create a basic cluster in GCP
resource "mongodbatlas_cluster" "run" {
  project_id   = mongodbatlas_project.run.id
  name         = terraform.workspace
  cluster_type = "REPLICASET"

  provider_backup_enabled      = false
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.2"

  //Provider Settings "block"
  provider_name               = "GCP"
  disk_size_gb                = 40
  provider_instance_size_name = "M30"
  provider_region_name        = var.mongodbatlas_region_name
}

# Whitelist access to the cluster from everywhere
# You would want to tweak this for a production scenario
resource "mongodbatlas_project_ip_whitelist" "run" {
  project_id = mongodbatlas_project.run.id
  cidr_block = "0.0.0.0/0"
  comment    = "Allow all"
}

# Create a database user for the application
resource "mongodbatlas_database_user" "run" {
  username           = "dbadmin"
  password = var.mongodbatlas_database_password
  project_id         = mongodbatlas_project.run.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }

}

# Random id for naming
resource "random_id" "id" {
  byte_length = 4
  prefix      = terraform.workspace
}

# Create a Google project for App Engine
resource "google_project" "project" {
  name            = terraform.workspace
  project_id      = random_id.id.hex
  billing_account = var.billing_account
  org_id          = var.org_id
}

# Enable the necessary services on the project for AppEngine deployments
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

# Enable any beta services for App Engine deployment with autoscaling
resource "google_project_service" "service_beta" {
    provider = google-beta
    project            = google_project.project.project_id
  disable_on_destroy = false
  service = "compute.googleapis.com"
}

# Create the app engine for app deployment
resource "google_app_engine_application" "app" {
  project     = google_project.project.project_id
  location_id = var.location_id
}



############################
# OUTPUTS
############################

output "project_id" {
    value = google_project.project.project_id
}

output "plstring" {
    value = mongodbatlas_cluster.run.connection_strings[0]
}