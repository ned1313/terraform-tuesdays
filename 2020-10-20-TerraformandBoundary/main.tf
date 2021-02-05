######################################################################################
## Providers
######################################################################################

provider "boundary" {
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}

######################################################################################
## Variables
######################################################################################

variable "user" {
  type    = string
  default = "Ned"
}

variable "backend_server_ips" {
  type    = set(string)
  default = [
    "10.1.0.1",
    "10.1.0.2",
  ]
}

######################################################################################
## Resources
######################################################################################

resource "boundary_scope" "global" {
  global_scope = true
  description  = "Ned's Taco Empire"
  scope_id     = "global" # Global is at the top of the tree
}

# Org scope goes inside global scope
resource "boundary_scope" "hut_one" {
  name                     = "Taco Hut One"
  description              = "Hut One Scope"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

## Select an auth method for the org scope
# This will be used by the project scopes
resource "boundary_auth_method" "password" {
  name     = "Password Auth One"
  scope_id = boundary_scope.hut_one.id
  type     = "password"
}

# Create accounts for the org scope in the auth method of choice
resource "boundary_account" "user_acct" {
  name           = var.user
  description    = "User account for ${var.user}"
  type           = "password"
  login_name     = lower(var.user)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

# Users are associated with auth method accounts
resource "boundary_user" "user" {
  name        = var.user
  description = "User resource for ${var.user}"
  account_ids = [boundary_account.user_acct.id]
  scope_id    = boundary_scope.hut_one.id
}

# Give Ned admin, he's earned it
resource "boundary_role" "organization_admin" {
  name        = "admin"
  description = "Administrator role"
  principal_ids = [boundary_user.user.id]
  grant_strings   = ["id=*;type=*;actions=create,read,update,delete"]
  scope_id = boundary_scope.hut_one.id
}

# Now we'll create a project scope inside the org scope
resource "boundary_scope" "hut_one_infra" {
  name                   = "Hut One Infra"
  description            = "Infra for Hut One"
  scope_id               = boundary_scope.hut_one.id
  auto_create_admin_role = true
}

# Create a catalog of backend servers I might want to access
resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Backend servers host catalog"
  type        = "static"
  scope_id    = boundary_scope.hut_one_infra.id
}

# Create backend servers in the host catalog
resource "boundary_host" "backend_servers" {
  for_each        = var.backend_server_ips
  type            = "static"
  name            = "backend_server_service_${each.value}"
  description     = "Backend server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

# Create a host set of the backend servers
resource "boundary_host_set" "backend_servers_ssh" {
  type            = "static"
  name            = "backend_servers_ssh"
  description     = "Host set for backend servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.backend_servers : host.id]
}

# Create target for accessing backend servers on port :22
resource "boundary_target" "backend_servers_ssh" {
  type         = "tcp"
  name         = "Backend servers"
  description  = "Backend SSH target"
  scope_id     = boundary_scope.hut_one_infra.id
  default_port = "22"

  host_set_ids = [
    boundary_host_set.backend_servers_ssh.id
  ]
}
