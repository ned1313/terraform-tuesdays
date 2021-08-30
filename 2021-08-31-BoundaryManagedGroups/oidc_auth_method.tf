provider "boundary" {
  addr = var.boundary_server
  auth_method_id = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}

module "azuread_oidc" {
  source = "./azure_oidc"
}

resource "boundary_scope" "org" {
  name                     = "organization_one"
  description              = "My first scope!"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_auth_method_oidc" "azuread" {
  scope_id = boundary_scope.org.id
  issuer = "https://login.microsoftonline.com/${module.azuread_oidc.tenant_id}/v2.0"
  client_id = module.azuread_oidc.client_id
  client_secret = module.azuread_oidc.client_secret
  callback_url = "${var.boundary_server}/v1/auth-methods/oidc:authenticate:callback"
  signing_algorithms = ["RS256"]
  api_url_prefix = var.boundary_server
  name = "azuread"
  is_primary_for_scope = true

}

resource "boundary_managed_group" "azuread" {
  auth_method_id = boundary_auth_method_oidc.azuread.id
  description = "Boundary Admins managed group"
  name = "BoundaryAdmins"
  filter = "\"${module.azuread_oidc.group_id}\" in \"/token/groups\""
}

resource "boundary_role" "project_admin" {
  scope_id = boundary_scope.org.id

  grant_strings = ["id=*;type=*;actions=*"]
  principal_ids = [boundary_managed_group.azuread.id]

}

output "grant_command" {
  value = module.azuread_oidc.grant_command
}