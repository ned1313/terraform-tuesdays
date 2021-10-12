# Create a project for the resources hosting the application
module "project" {
  source          = "./project_creation"
  billing_account = var.billing_account
  org_id          = var.org_id
  region          = var.region
  prefix          = random_id.id.hex
}

# Create a service account

resource "google_service_account" "service_account" {
  account_id   = local.gcp_service_account_name
  display_name = local.gcp_service_account_name
  project      = module.project.project_id
}

# Private IP address for Cloud SQL

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  project      = module.project.project_id

  name          = "vort-db-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.votr-network.id
}

# Private IP connection for DB

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.votr-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create Cloud SQL instance

resource "google_sql_database_instance" "votr" {
  name             = local.cloud_sql_instance_name
  database_version = var.database_version
  region           = var.region
  project      = module.project.project_id

  deletion_protection = false

  settings {
    
    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.votr-network.id
    }

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }

  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Create a database instance

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.votr.name
  project      = module.project.project_id
}

# Set the root password

resource "random_password" "mysql_root" {
    length = 16
    special = true
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.votr.name
  type     = "BUILT_IN"
  project                 = module.project.project_id
  password = random_password.mysql_root.result
}

# Grant service account access to Cloud SQL as a client

resource "google_sql_user" "votr" {
  name     = google_service_account.service_account.email
  instance = google_sql_database_instance.votr.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project                 = module.project.project_id
}

resource "google_project_iam_member" "sql_client" {
    project                 = module.project.project_id
    role = "roles/cloudsql.client"
    member = "serviceAccount:${google_service_account.service_account.email}"

}

resource "google_project_iam_member" "sql_instance" {
    project                 = module.project.project_id
    role = "roles/cloudsql.instanceUser"
    member = "serviceAccount:${google_service_account.service_account.email}"

}

# Create a VPC for the application
resource "google_compute_network" "votr-network" {
  name                    = var.network_name
  project                 = module.project.project_id
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "votr-subnetwork" {
  project       = module.project.project_id
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = google_compute_network.votr-network.name
}

resource "google_compute_router" "default" {
  name    = "${var.network_name}-router"
  network = google_compute_network.votr-network.self_link
  region  = var.region
  project = module.project.project_id
}

resource "google_compute_router_nat" "nat" {
  project                            = module.project.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "http" {
  project     = module.project.project_id
  name        = "${var.network_name}-http-allow"
  network     = google_compute_network.votr-network.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80"]
  }
  target_tags = ["allow-http"]
}

/*****************************************
  Runner Secrets
 *****************************************/
resource "google_secret_manager_secret" "votr-secret" {
  provider  = google-beta
  project   = module.project.project_id
  secret_id = "votr-token"

  labels = {
    label = "votr-sql-connect"
  }

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}
resource "google_secret_manager_secret_version" "votr-secret-version" {
  provider = google-beta
  secret   = google_secret_manager_secret.votr-secret.id
  secret_data = jsonencode({
    "DB_USER"     = "root"
    "DB_PASS"      = random_password.mysql_root.result
    "DB_NAME" = var.database_name
    "DB_HOST" = "${google_sql_database_instance.votr.private_ip_address}:3306"
  })
}


resource "google_secret_manager_secret_iam_member" "votr-secret-member" {
  provider  = google-beta
  project   = module.project.project_id
  secret_id = google_secret_manager_secret.votr-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}

/*****************************************
  Runner GCE Instance Template
 *****************************************/
locals {
  instance_name = "votr-runner-vm"
}


module "mig_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 7.0"
  project_id         = module.project.project_id
  machine_type       = var.machine_type
  network            = var.network_name
  subnetwork         = var.subnet_name
  region             = var.region
  subnetwork_project = module.project.project_id
  service_account = {
    email = google_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 10
  disk_type            = "pd-ssd"
  auto_delete          = true
  name_prefix          = var.instance_name
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  startup_script       = file("${path.module}/scripts/startup.sh")
  source_image         = var.source_image
  metadata = {
    "secret-id" = google_secret_manager_secret_version.votr-secret-version.name
    }
  tags = [
    "votr-runner-vm", "allow-http"
  ]
}
/*****************************************
  Runner MIG
 *****************************************/
module "mig" {
  source             = "terraform-google-modules/vm/google//modules/mig"
  version            = "~> 7.0"
  project_id         = module.project.project_id
  subnetwork_project = module.project.project_id
  hostname           = var.instance_name
  region             = var.region
  instance_template  = module.mig_template.self_link
  target_size        = var.target_size

  /* autoscaler */
  autoscaling_enabled = true
  cooldown_period     = var.cooldown_period
}

################################################
# Add Load Balancer
################################################

module "lb-http" {
    source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 5.0"
  name    = var.prefix
  project = module.project.project_id
  target_tags = [
    google_compute_router.default.name,
    google_compute_subnetwork.votr-subnetwork.name
  ]
  firewall_networks = [google_compute_network.votr-network.name]

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}