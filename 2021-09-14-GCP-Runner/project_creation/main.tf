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
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  service = each.key

  project            = google_project.project.project_id
  disable_on_destroy = false
}